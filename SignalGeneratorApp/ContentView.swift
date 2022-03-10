//
//  ContentView.swift
//  SignalGeneratorApp
//
//  Created by Mark Erbaugh on 2/28/22.
//

import SwiftUI
import simd

fileprivate struct Settings {
    static let tone1 = 700.0
    static let tone2 = 1900.0
}


struct ContentView: View {
    
    @StateObject private var signalGenerator = SignalGenerator(frequency1: Settings.tone1, frequency2: Settings.tone2)
    @State private var mixerLevel = 0.0
    @State private var balance = 0.5
    @State private var outputLabel = "Default Output"
    
    var body: some View {
        VStack {
            Menu(outputLabel) {
                ForEach(Audio.getOutputDevices().sorted(by: >), id: \.key) {(key, value) in
                    Button(value) {
                        signalGenerator.setOutputDevice(key)
                        outputLabel = value
                    }
                }
            }
            HStack {
                Button("Level") {
                    mixerLevel = 0
                }
                Slider(value: $mixerLevel, in: 0...5.0)
                    .onChange(of: mixerLevel) {signalGenerator.mainMixer.outputVolume = Float($0)}
            }
            HStack {
                Button("Balance") {
                    balance = 0.5
                }
                HStack {
                    Text("\(Int(Settings.tone1))")
                    Slider(value: $balance, in: 0...1.0)
                        .onChange(of: balance) {signalGenerator.balance = $0}
                    Text("\(Int(Settings.tone2))")
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
