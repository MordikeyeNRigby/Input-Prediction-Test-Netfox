class_name Utils

#takes a vector, and clamps/interpolates its length (direction stays the same) between 0 and a maxmimum length based on the vectors position relative to an inner radius and outer radius.
#this is basically the function that defines how a character should move relative to the mouse position
static func ClampLerpVectRad(innerRad: float, outerRad: float, vect: Vector2, maxLength: float) -> Vector2:
	var v: Vector2 = vect
	var t: float = (v.length() - outerRad) / (innerRad - outerRad)
	var length: float = lerp(maxLength,0.0,t)
	if length < 0: length = 0
	elif length > maxLength: length = maxLength
	v = v.normalized() * length
	return v

static func GetCleanBuffer() -> StreamPeerBuffer:
	var buffer := StreamPeerBuffer.new()
	buffer.resize(256)
	buffer.seek(0)
	return buffer

static func GetBuffer(data: PackedByteArray) -> StreamPeerBuffer:
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(data)
	buffer.seek(0)
	return buffer

static func SerializeVect(v: Vector2) -> PackedByteArray:
	var buffer := StreamPeerBuffer.new()
	buffer.put_float(v.x)
	buffer.put_float(v.y)
	buffer.resize(buffer.get_position())
	return buffer.data_array

static func DeserializeVect(buffer: StreamPeerBuffer) -> Vector2:
	return Vector2(buffer.get_float(),buffer.get_float())

#this guy lets you increment towards a target vector2 at a constant speed without overshooting. as soon as its past the target location, it will snap to the target location.
static func SnapInterpVect(target: Vector2, current: Vector2, speed: float):
	var delta: Vector2 = target - current
	var newV: Vector2 = current + delta.normalized() * speed
	var newDel: Vector2 = target - newV
	if sign(newDel.x) != sign(delta.x) || sign(newDel.y) != sign(delta.y):
		newV = target
	return newV
