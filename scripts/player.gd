extends CharacterBody2D

# Kecepatan bergerak karakter (pixel per detik)
const SPEED = 300.0

# Menyimpan arah hadap terakhir karakter agar saat diam (idle) tetap menghadap ke arah terakhir
var last_direction: Vector2 = Vector2.RIGHT

# Mengambil referensi node AnimatedSprite2D saat scene sudah siap
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# Loop fisika yang dijalankan di setiap frame (biasanya 60 FPS)
func _physics_process(_delta: float) -> void:
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
	else:
		# Jika tidak ada tombol yang ditekan (pemain berhenti):
		velocity = Vector2.ZERO          # Hentikan pergerakan karakter

# Fungsi untuk menentukan status animasi (lari atau diam) berdasarkan velocity dan last_direction
func process_animation() -> void:
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
