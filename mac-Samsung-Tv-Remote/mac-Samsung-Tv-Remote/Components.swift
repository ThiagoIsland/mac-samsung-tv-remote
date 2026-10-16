//
//  Components.swift
//  mac-Samsung-Tv-Remote
//
//  Created by Thiago Alessandro  on 16/10/26.
//

import SwiftUI

struct TrackpadArea: View {
    var action: ([String]) -> Void
    @State private var lastDragPosition: CGSize = .zero
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(white: isHovered ? 0.11 : 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(isHovered ? 0.15 : 0.05), lineWidth: 1)
                )
            
            VStack(spacing: 12) {
                Image(systemName: "cursorarrow")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(Color.gray.opacity(isHovered ? 1.0 : 0.8))
                
                Text("Trackpad")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color.gray.opacity(isHovered ? 1.0 : 0.8))
                
                Text("Deslize para mover, clique para OK")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
        }
        .frame(height: 140)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(.easeOut(duration: 0.2), value: isHovered)
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    let deltaX = value.translation.width - lastDragPosition.width
                    let deltaY = value.translation.height - lastDragPosition.height
                    let threshold: CGFloat = 25
                    
                    if abs(deltaX) > threshold {
                        action(["send-key", deltaX > 0 ? "KEY_RIGHT" : "KEY_LEFT"])
                        lastDragPosition.width = value.translation.width
                    }
                    
                    if abs(deltaY) > threshold {
                        action(["send-key", deltaY > 0 ? "KEY_DOWN" : "KEY_UP"])
                        lastDragPosition.height = value.translation.height
                    }
                }
                .onEnded { _ in
                    lastDragPosition = .zero
                }
        )
        .onTapGesture {
            action(["send-key", "KEY_ENTER"])
        }
    }
}

struct MediaButton: View {
    var icon: String
    var isPrimary: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: isPrimary ? 24 : 20, weight: .semibold))
                .foregroundColor(isPrimary ? .white : .gray)
                .frame(width: isPrimary ? 65 : 50, height: isPrimary ? 65 : 50)
                .background(isPrimary ? Color.blue : Color(white: 0.2))
                .clipShape(Circle())
        }.buttonStyle(HoverBouncyButtonStyle())
    }
}

struct ConsoleCard: View {
    var title: String
    var subtitle: String
    var port: String
    var icon: String
    var imageName: String? = nil
    var colors: [Color]
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 110)
                    
                    VStack(spacing: 12) {
                        if let img = imageName {
                            Image(img)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                        } else {
                            Image(systemName: icon)
                                .font(.system(size: 30, weight: .light))
                                .foregroundColor(.white)
                        }
                        
                        Text(title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                    }
                }
                
                HStack {
                    Circle().fill(Color.green).frame(width: 6, height: 6)
                    Text("PRONTO")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(port)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 4)
            }
        }
        .buttonStyle(HoverBouncyButtonStyle())
    }
}

struct NavBarIcon: View {
    var icon: String
    var isActive: Bool
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 20, weight: isActive ? .semibold : .regular))
            .foregroundColor(isActive ? .blue : .gray)
            .frame(width: 55, height: 45)
            .background(isActive ? Color.blue.opacity(0.15) : Color.clear)
            .cornerRadius(12)
    }
}

struct AppIcon: View {
    var app: TVApp
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if let img = app.imageName {
                    Image(img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 65, height: 65)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: app.color.opacity(0.3), radius: 8, y: 4)
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(app.color)
                        .frame(width: 65, height: 65)
                        .overlay(
                            Text(String(app.name.prefix(1)))
                                .font(.system(.title, design: .rounded).weight(.bold))
                                .foregroundColor(app.textColor)
                        )
                        .shadow(color: app.color.opacity(0.3), radius: 8, y: 4)
                }
                
                Text(app.name)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(HoverBouncyButtonStyle())
    }
}
