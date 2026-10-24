extends CharacterBody2D

# Kecepatan gerak musuh saat mengejar pemain (pixel per detik)
const SPEED: int = 100
# Kekuatan daya dorong terpental saat terkena tebasan (pixel)
const KNOCKBACK_FORCE: int = 100

# Status kehidupan dan darah musuh
var is_alive: bool = true
var health: int = 100
var target = null                      # Referensi node pemain jika masuk ke area pandang (Sight)

# Referensi node anak
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var health_bar: Node2D = $HealthBar

# Loop fisika yang berjalan stabil 60 FPS
func _physics_process(delta: float) -> void:	
	# Jika masih hidup dan ada target pemain di area pandang, dekati target
	if is_alive and target:
		_attack(delta)

# Logika AI mengejar pemain
func _attack(delta: float) -> void:
	# Hitung vektor arah normalisasi dari posisi musuh menuju pemain
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animated_sprite_2d.play("attack")

# Fungsi menerima serangan dari tebasan pedang pemain
func take_damage(damage: int, attacker_position: Vector2) -> void:
	health -= damage
	health_bar.update_health(health)    # Perbarui visual bar darah
	print(health)
	
	if health <= 0:
		_die()
	else:
		take_damage_sound.play()        # Putar SFX terkena tebasan
		
		# Hitung arah pantulan menjauhi posisi penyerang
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction * KNOCKBACK_FORCE
		
		# Animasi dorongan halus (Knockback) menggunakan Tween
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", target_position, 0.5)

# Fungsi penanganan saat musuh mati (HP habis)
func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("die")      # Putar animasi hancur/meleleh
	
	# Turunkan nada audio untuk efek suara kematian yang lebih berat/dramatis
	take_damage_sound.pitch_scale = 0.5
	take_damage_sound.play()
	
	# Nonaktifkan tabrakan fisik & sensor penglihatan secara aman (deferred)
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)

# Callback saat ada objek masuk ke area deteksi penglihatan
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body                   # Kunci target ke Player

# Callback saat objek keluar dari area deteksi penglihatan
func _on_sight_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player" and is_alive:
		target = null                   # Lepaskan target jika pemain kabur
		animated_sprite_2d.play("idle")

