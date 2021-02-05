//tyvm cecil
global.wait = {
    Waiter: function(_f) constructor{
        f_max = _f
        f_cur = _f
        f_fin = false
    },
    do_wait: function(_waiter){
        if (_waiter.f_cur == -1 && _waiter.f_fin) return false
        else if (_waiter.f_cur > 0 && !_waiter.f_fin){
            _waiter.f_cur--
            return false
        }
        else if (_waiter.f_cur == 0 && !_waiter.f_fin){
            _waiter.frame_fin = true
            return true
        }
    },
    reset: function(_waiter){
        _waiter.f_cur = _waiter.f_max
        _waiter.f_fin = false
    },
    overwrite: function(_waiter, _f){
        _waiter.f_max = _f
        _waiter.f_cur = _f
        _waiter.f_fin = false
    },
    once: function(_waiter){
        _waiter.f_cur = -1
        _waiter.f_fin = true
    }
}

