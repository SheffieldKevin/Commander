// Playground - noun: a place where people can play

import Cocoa

func returnDarkBlueColourTuple1() -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
    return (0.02, 0.1, 0.35)
}

func returnDarkBlueColourTuple2() -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
    return (green: 0.1, blue: 0.35, red: 0.02)
}

let tuple1 = returnDarkBlueColourTuple1()
println("red component: \(tuple1.red)")
println("red component: \(tuple1.0)")

// This form works
func printColor(comment: String, #red: CGFloat, #green: CGFloat, #blue: CGFloat) {
    println("PrintColor - red: \(red), green: \(green), blue: \(blue)")
}

// This form doesn't
// func printColor(#red: CGFloat, #green: CGFloat, #blue: CGFloat) {
//    println("PrintColor - red: \(red), green: \(green), blue: \(blue)")
// }

printColor("Color comment", red: tuple1.red, green: tuple1.green, blue: tuple1.blue)

let tuple2 = returnDarkBlueColourTuple2()

println("tuple2 component 0 \(tuple2.0)")
