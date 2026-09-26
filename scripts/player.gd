extends CharacterBody2D

# Kecepatan bergerak karakter (pixel per detik)
const SPEED = 300.0

# Menyimpan arah hadap terakhir karakter agar saat diam (idle) tetap menghadap ke arah terakhir
var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false         # Menandai apakah pemain sedang menyerang
var hitbox_offset: Vector2             # Menyimpan offset posisi default hitbox

# Mengambil referensi node saat scene sudah siap
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_sword: AudioStreamPlayer2D = $SwingSword
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	# Inisialisasi posisi awal offset Hitbox dari scene editor
	hitbox_offset = hitbox.position
	
# Loop fisika yang dijalankan di setiap frame (biasanya 60 FPS)
func _physics_process(_delta: float) -> void:
	# Matikan sensor pedang secara default di setiap frame
	hitbox.monitoring = false
	
	# Cek input serangan jika tidak sedang menyerang
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	
	# Movement Lock: Hentikan gerak jika sedang mengayunkan pedang
	if is_attacking:
		velocity = Vector2.ZERO
		return
	
	process_movement()                 # 1. Menghitung kecepatan berdasarkan input pemain
	process_animation()                # 2. Memilih animasi yang sesuai (run/idle + arah)
	move_and_slide()                   # 3. Menggerakkan karakter & menangani tabrakan (collision)

# ======================================
# MOVEMENT & ANIMATION
# ======================================
# Fungsi untuk memproses input pergerakan pemain
func process_movement() -> void:
	# Membaca input 4 arah (kiri, kanan, atas, bawah) dan otomatis mengembalikan vektor yang ternormalisasi
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		# Jika ada tombol arah yang ditekan:
		velocity = direction * SPEED     # Set kecepatan gerak karakter
		last_direction = direction       # Simpan arah ini sebagai arah terakhir
		update_hitbox_offset()           # Perbarui posisi kotak hitbox sesuai arah hadap
	else:
		# Jika tidak ada tombol yang ditekan (pemain berhenti):
		velocity = Vector2.ZERO          # Hentikan pergerakan karakter

# Fungsi untuk menentukan status animasi (lari atau diam) berdasarkan velocity dan last_direction
func process_animation() -> void:
	# Jangan ubah animasi jika sedang dalam animasi serang
	if is_attacking:
		return
		
	if velocity != Vector2.ZERO:
		# Jika karakter sedang bergerak, putar animasi lari ("run") sesuai arah terakhir
		play_animation("run", last_direction)
	else: 
		# Jika karakter diam, putar animasi diam ("idle") sesuai arah terakhir
		play_animation("idle", last_direction)

# Fungsi pembantu untuk memutar animasi sesuai awalan (prefix) dan arah hadap (dir)
func play_animation(prefix: String, dir: Vector2) -> void:
	# Prioritas arah horizontal (kiri / kanan)
	if dir.x != 0:
		# Jika bergerak ke kiri (dir.x < 0), balik sprite secara horizontal (flip_h = true)
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	# Arah vertikal ke atas
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	# Arah vertikal ke bawah
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")

# ======================================
# ATTACKING
# ======================================
# Fungsi untuk mengeksekusi aksi serangan
func attack() -> void:
	is_attacking = true
	hitbox.monitoring = true                 # Aktifkan sensor pedang saat menyerang
	swing_sword.play()                       # Putar efek suara ayunan pedang
	play_animation("attack", last_direction) # Putar animasi tebasan sesuai arah hadap

# Callback saat animasi sprite selesai diputar
func _on_animated_sprite_2d_animation_finished() -> void:
	# Reset status serang agar pemain bisa kembali bergerak
	if is_attacking:
		is_attacking = false

# ======================================
# HITBOX OFFSET
# ======================================
# Fungsi untuk merotasi posisi hitbox sesuai arah hadap karakter
func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	# Pola rotasi koordinat 4-arah
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
		Vector2.DOWN:
			hitbox.position = Vector2(-y, x)

# Callback saat hitbox mengenai badan objek lain
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Deteksi jika sabetan mengenai musuh Slime
	if is_attacking and body.name.begins_with("Slime"):
		print(body.name)
