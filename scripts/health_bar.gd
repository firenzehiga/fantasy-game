extends Node2D

# Referensi node sprite bar darah
@onready var health_bar: Sprite2D = $Health
# Simpan ukuran piksel asli tekstur bar darah dari inspector
@onready var default_width = health_bar.region_rect.size.x
@onready var default_height = health_bar.region_rect.size.y

# Fungsi untuk memperbarui lebar visual bar darah secara dinamis
func update_health(new_health: int) -> void:
	# Hitung lebar baru secara proporsional terhadap HP maksimum (100.0)
	var new_width = (new_health / 100.0) * default_width
	# Potong tampilan tekstur sprite menggunakan Rect2 (X, Y, Lebar, Tinggi)
	health_bar.region_rect = Rect2(0, 0, new_width, default_height)

