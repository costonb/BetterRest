//
//  ContentView.swift
//  BetterRest
//
//  Created by Brandon Coston on 2/28/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var bedtime: Text {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let componets = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (componets.hour ?? 0) * 60 * 60
            let minute = (componets.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return Text("Bedtime: \(sleepTime.formatted(date: .omitted, time: .shortened))").foregroundColor(.blue)
        } catch {
            return Text("Sorry, there was a problem calculating your bedtime").foregroundColor(.red)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When do you want to wake up?")
                            .font(.headline)
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Picker("Daily cups of coffee", selection: $coffeeAmount) {
                            ForEach(0..<21) { amount in
                                Text(amount == 1 ? "1 cup" : "\(amount) cups")
                            }
                        }
                    }
                }
                .navigationTitle("BetterRest")
                bedtime
                    .font(.largeTitle)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
