#!/usr/bin/env swift

import Cocoa
import AVFoundation

let movieFilePaths = [
    "/Users/ktam/Movies/clips/418_clip1_sd.m4v",
    "/Users/ktam/Movies/clips/418_clip2_sd.m4v",
    "/Users/ktam/Movies/clips/418_clip3_sd.m4v",
    "/Users/ktam/Movies/clips/418_clip4_sd.m4v",
    "/Users/ktam/Movies/clips/418_clip5_sd.m4v",
    "/Users/ktam/Movies/clips/418_clip6_sd.m4v"
]

// Convert file paths into file URLs
let urls = movieFilePaths.map { NSURL(fileURLWithPath:$0, isDirectory:false)! }

// Make movie assets from the URLs.
// let movieAssets: [AVURLAsset] = urls.map { AVURLAsset(URL:$0, options:.None)! }

let movieAssets = urls.map { AVURLAsset(URL:$0, options:.None)! }

// println("Video asset 1 duration: \(movieAssets[0].duration.value)")

// Set the transition duration time to one second.
let transDuration = CMTimeMake(1, 1)

// Cursor time represents the time we are currently at in the movie.
var cursorTime = kCMTimeZero

var passThroughTimeRanges:[NSValue] = [NSValue]()
var transitionTimeRanges:[NSValue] = [NSValue]()

for (var i = 0 ; i < movieAssets.count ; ++i)
{
    let asset = movieAssets[i]
    var timeRange = CMTimeRangeMake(cursorTime, asset.duration)
    
    if i > 0 {
        timeRange.start = CMTimeAdd(timeRange.start, transDuration)
        timeRange.duration = CMTimeSubtract(timeRange.duration, transDuration)
    }
    
    if i + 1 < movieAssets.count {
      timeRange.duration = CMTimeSubtract(timeRange.duration, transDuration)
    }
    
    passThroughTimeRanges.append(NSValue(CMTimeRange: timeRange))
    cursorTime = CMTimeAdd(cursorTime, asset.duration)
    cursorTime = CMTimeSubtract(cursorTime, transDuration)
    println("cursorTime.value: \(cursorTime.value)")
    println("cursorTime.timescale: \(cursorTime.timescale)")
    
    if i + 1 < movieAssets.count {
      timeRange = CMTimeRangeMake(cursorTime, transDuration)
      println("timeRange start value: \(timeRange.start")
      transitionTimeRanges.append(NSValue(CMTimeRange: timeRange))
    }
}

println("Number of pass through time ranges: \(passThroughTimeRanges.count)")
println("Number of transition time ranges: \(transitionTimeRanges.count)")

