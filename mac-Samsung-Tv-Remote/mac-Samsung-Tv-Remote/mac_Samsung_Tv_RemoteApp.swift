//
//  mac_Samsung_Tv_RemoteApp.swift
//  mac-Samsung-Tv-Remote
//
//  Created by Thiago Alessandro  on 13/10/26.
//

import SwiftUI

@main
struct SamsungTVRemoteApp: App {
    var body: some Scene {
        // MenuBarExtra é o que faz o app morar na barra superior do Mac!
        MenuBarExtra("TV Remote", systemImage: "tv") {
            ContentView()
        }
        .menuBarExtraStyle(.window) // Garante que abra como um popover/janela
    }
}
