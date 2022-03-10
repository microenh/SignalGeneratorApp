/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The main source file for SignalGenerator.
 */

import Foundation
import AVFoundation
import SwiftUI

fileprivate struct Settings {
    static let sampleRate = 8000.0
}

class SignalGenerator: ObservableObject {
    
    @Published var playing = false
    
    private let nco1: NCOCosine
    private let nco2: NCOCosine

    private let engine: AVAudioEngine
    let mainMixer: AVAudioMixerNode
    private let output: AVAudioOutputNode
    var balance = 0.5
    
    init(frequency1: Double, frequency2: Double) {
        nco1 = NCOCosine(frequency: frequency1, sampleRate: Settings.sampleRate)
        nco2 = NCOCosine(frequency: frequency2, sampleRate: Settings.sampleRate)
        engine = AVAudioEngine()
        mainMixer = engine.mainMixerNode
        output = engine.outputNode
        
        let ncoFormat = AVAudioFormat(commonFormat: .pcmFormatFloat64,
                                    sampleRate: Settings.sampleRate,
                                    interleaved: false,
                                    channelLayout: AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_Mono)!)
        
        let srcNode = AVAudioSourceNode(format: ncoFormat) { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            if let self = self {
                let buf: UnsafeMutableBufferPointer<Double> = UnsafeMutableBufferPointer(UnsafeMutableAudioBufferListPointer(audioBufferList)[0])
                for frame in 0..<Int(frameCount) {
                    buf[frame] = self.balance * self.nco2.value + (1.0 - self.balance) * self.nco1.value
                }
            }
            return noErr
        }
        
        engine.attach(srcNode)
        engine.connect(srcNode, to: mainMixer, format: output.inputFormat(forBus: 0))
        engine.connect(mainMixer, to: output, format: output.inputFormat(forBus: 0))
        mainMixer.outputVolume = 0
        do {
            try engine.start()
            playing = true
        } catch {
            print("Could not start engine: \(error)")
        }
    }
    
    func setOutputDevice(_ outputDevice: UInt32) {
        if let outputUnit = output.audioUnit {
            // use core audio low level call to set the input device:
            var outputDeviceID: AudioDeviceID = outputDevice  // replace with actual, dynamic value
            AudioUnitSetProperty(outputUnit,
                                 kAudioOutputUnitProperty_CurrentDevice,
                                 kAudioUnitScope_Global,
                                 0,
                                 &outputDeviceID,
                                 UInt32(MemoryLayout<AudioDeviceID>.size))
        }
    }    
}
