//
//  Models.swift
//  mac-Samsung-Tv-Remote
//
//  Created by Thiago Alessandro  on 16/10/26.
//

import SwiftUI

// MODELO DE DADOS PARA AS APLICAÇÕES
struct TVApp: Identifiable, Equatable {
    let id: String
    let name: String
    let color: Color
    var textColor: Color = .white
    var imageName: String? = nil
    
    static func == (lhs: TVApp, rhs: TVApp) -> Bool {
        return lhs.id == rhs.id
    }
}

// ESTADO ATUAL DA TV (Para mostrar no ecrã)
enum ActiveSource: Equatable {
    case none
    case app(TVApp)
    case console(title: String, icon: String, imageName: String?, color: Color)
}
