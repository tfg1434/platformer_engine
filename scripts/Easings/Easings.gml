//Easing functions
//percent: (0.0 to 1.0)
//elapsed: Number of ms this has been running
//start: value to start at
//end: value to end at
//duration: length of animation in ms

///@func ease_in_quad(percent, elapsed, start, end, dur)
function ease_in_quad(x, t, b, c, d) {
    return c * (t / d) * t + b
}

