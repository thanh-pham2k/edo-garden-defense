extends RefCounted

## Body sheets use a bottom contact with 6 px of padding at 128 px,
## or 8 px for the larger 192 px cells.
static func set_sheet(sprite: Sprite2D, texture: Texture2D, grid: Vector2i) -> void:
	sprite.frame = 0
	sprite.texture = texture
	sprite.hframes = grid.x
	sprite.vframes = grid.y
	var cell_height := float(texture.get_height()) / float(grid.y)
	var padding := 2.0 + cell_height / 32.0
	sprite.offset.y = padding - cell_height * 0.5


static func set_contact_pixel(sprite: Sprite2D, contact_y: float) -> void:
	var cell_height := float(sprite.texture.get_height()) / float(sprite.vframes)
	sprite.offset.y = cell_height * 0.5 - contact_y
