--------
-- Simplest camera script.
--------

function update(dt, cameraIndex)

  -- Get AC camera parameters with some corrections to be somewhat compatible:
  local cameraParameters = ac.getCameraParameters(cameraIndex)
  local distance = cameraParameters.distance + 0.8
  local height = cameraParameters.height

  -- Get car position and vectors:
  local carPos = ac.getCarPosition()
  local carDir = ac.getCarDirection()

  -- Set camera parameters:
  ac.Camera.position = carPos - carDir * distance + vec3(0, height, 0)
  ac.Camera.direction = (carPos + carDir * 5 - ac.Camera.position):normalize()
  ac.Camera.up = vec3(0, 1, 0)
  ac.Camera.fov = 60

end