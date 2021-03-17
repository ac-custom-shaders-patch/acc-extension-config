ffi.cdef [[ 
typedef struct {
  void* host_;
  void* nativeEvent_;
  float volume;
  float pitch;
  float cameraInteriorMultiplier;
  float cameraExteriorMultiplier;
  float cameraTrackMultiplier;
  bool inAutoLoopMode;
} audioevent;
]]

-- bool padding_[7];

ac.AudioEvent = function (s, reverbResponse) 
  local created = ffi.C.lj_audioevent_new(tostring(s), reverbResponse and true or false) 
  return ffi.gc(created, ffi.C.lj_audioevent_gc) 
end

__audioEventKeepAlive = {}

ffi.metatype('audioevent', {
  __index = function(self, key) 
    if key == 'setPosition' then return function (s, pos, dir, up, vel) 
      ffi.C.lj_audioevent_set_pos(s, pos, dir or vec3.new(0, 0, 1), up or vec3.new(0, 1, 0), vel or vec3.new(0, 0, 0)) 
    end end
    if key == 'keepAlive' then return function (s) __audioEventKeepAlive[#__audioEventKeepAlive + 1] = s end end
    if key == 'setParam' then return ffi.C.lj_audioevent_set_param end
    if key == 'isValid' then return function (s) return s.host_ ~= nil and s.nativeEvent_ ~= nil end end
    if key == 'isPlaying' then return ffi.C.lj_audioevent_is_playing end
    if key == 'isPaused' then return ffi.C.lj_audioevent_is_paused end
    if key == 'isWithinRange' then return ffi.C.lj_audioevent_is_within_range end
    if key == 'resume' then return ffi.C.lj_audioevent_resume end
    if key == 'resumeIf' then return ffi.C.lj_audioevent_resume_if end
    if key == 'stop' then return ffi.C.lj_audioevent_stop end
    if key == 'start' then return ffi.C.lj_audioevent_start end
    error('audioevent has no member called \'' .. key .. '\'')
  end,
  __newindex = function(self, key, value) 
    error('audioevent has no member called \'' .. key .. '\'')
  end,
})