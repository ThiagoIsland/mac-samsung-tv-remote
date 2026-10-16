//
//  ContentView.swift
//  mac-Samsung-Tv-Remote
//
//  Created by Thiago Alessandro  on 13/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var volume: Double = 14
    @State private var isMuted: Bool = false
    @State private var currentTab: Int = 0 // 0 = TV, 1 = Controle, 2 = Apps, 3 = Configurações
    @State private var tvTextInput: String = ""
    
    // Estados para a nova aba de Configurações
    @State private var brightness: Double = 50
    @State private var pictureMode: String = "Padrão"
    @State private var isGameMode: Bool = false
    
    @State private var activeSource: ActiveSource = .none
    
    @State private var favoriteAppIDs: Set<String> = [
        "11101200001", "111299001912", "3201512006785", "3201901017640"
    ]
    
    let tvIP = "PUT_YOUR_IP_HERE"
    let authToken = "PUT_YOUR_TOKEN_HERE"
    
    // Lista de Aplicações atualizada com as imagens corretas
    let allApps: [TVApp] = [
        TVApp(id: "11101200001", name: "Netflix", color: .red, imageName: "netflix"),
        TVApp(id: "111299001912", name: "YouTube", color: .white, textColor: .black, imageName: "youtube"),
        TVApp(id: "3201512006785", name: "Prime", color: .blue, imageName: "primevideo"),
        TVApp(id: "3201901017640", name: "Disney+", color: .indigo, imageName: "disneyplus"),
        TVApp(id: "3201601007250", name: "Globoplay", color: .black, imageName: "globoplay"),
        TVApp(id: "3201606009684", name: "Spotify", color: .green, imageName: "spotify"),
        TVApp(id: "111399002220", name: "Apple TV", color: .gray, imageName: "Apple_TV"),
        TVApp(id: "3201512006320", name: "Max", color: .purple, imageName: "hbomax")
    ]
    
    // Cor dinâmica baseada no que está a passar na TV (para o brilho do monitor)
    var activeColor: Color {
        switch activeSource {
        case .none: return Color.black
        case .app(let app): return app.color
        case .console(_, _, _, let color): return color
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. BARRA DE NAVEGAÇÃO SUPERIOR
            HStack(spacing: 15) {
                Button(action: { currentTab = 0 }) {
                    NavBarIcon(icon: "tv", isActive: currentTab == 0)
                }.buttonStyle(HoverBouncyButtonStyle())
                
                Button(action: { currentTab = 1 }) {
                    NavBarIcon(icon: "av.remote", isActive: currentTab == 1)
                }.buttonStyle(HoverBouncyButtonStyle())
                
                Button(action: { currentTab = 2 }) {
                    NavBarIcon(icon: "square.grid.2x2", isActive: currentTab == 2)
                }.buttonStyle(HoverBouncyButtonStyle())
                
                // ABA DE CONFIGURAÇÕES
                Button(action: { currentTab = 3 }) {
                    NavBarIcon(icon: "slider.horizontal.3", isActive: currentTab == 3)
                }.buttonStyle(HoverBouncyButtonStyle())
                
                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)
            .padding(.bottom, 15)
            
            // CONTEÚDO DINÂMICO
            if currentTab == 0 {
                // ==========================================
                // ABA 0: DASHBOARD DA TV
                // ==========================================
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // 1. ECRÃ DA TV (Monitor de Status)
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.05), Color.black]), startPoint: .top, endPoint: .bottom))
                                .shadow(color: activeColor.opacity(0.4), radius: 25, x: 0, y: 10)
                            
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.08), Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .padding(1)
                            
                            VStack {
                                switch activeSource {
                                case .none:
                                    Image(systemName: "tv")
                                        .font(.system(size: 40, weight: .light))
                                        .foregroundColor(Color(white: 0.4))
                                    Text("Sem Sinal")
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundColor(Color(white: 0.5))
                                        .padding(.top, 8)
                                        
                                case .app(let app):
                                    if let imageName = app.imageName {
                                        Image(imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 70, height: 70)
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .shadow(color: app.color.opacity(0.5), radius: 10, y: 5)
                                    } else {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(app.color)
                                            .frame(width: 70, height: 70)
                                            .overlay(
                                                Text(String(app.name.prefix(1)))
                                                    .font(.system(.title, design: .rounded).weight(.bold))
                                                    .foregroundColor(app.textColor)
                                            )
                                            .shadow(color: app.color.opacity(0.5), radius: 10, y: 5)
                                    }
                                    
                                    Text(app.name)
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.top, 8)
                                        
                                case .console(let title, let icon, let imageName, let color):
                                    if let img = imageName {
                                        Image(img)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 55, height: 55)
                                            .shadow(color: color.opacity(0.5), radius: 10, y: 5)
                                    } else {
                                        Image(systemName: icon)
                                            .font(.system(size: 55, weight: .light))
                                            .foregroundColor(color)
                                            .shadow(color: color.opacity(0.5), radius: 10, y: 5)
                                    }
                                    
                                    Text(title)
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.top, 8)
                                }
                            }
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: activeSource)
                        }
                        .frame(height: 190)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        
                        // 2. CARD DE VOLUME
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                    .foregroundColor(isMuted ? .red : .gray)
                                    .animation(.easeInOut(duration: 0.2), value: isMuted)
                                
                                Text("Áudio da TV").font(.system(.headline, design: .rounded))
                                Spacer()
                                Text("\(Int(volume))")
                                    .font(.system(.title2, design: .rounded).weight(.bold))
                                    .opacity(isMuted ? 0.4 : 1.0)
                            }
                            
                            HStack {
                                Image(systemName: "speaker.fill").foregroundColor(.gray).font(.caption)
                                Slider(value: $volume, in: 0...100, step: 1)
                                    .accentColor(isMuted ? .gray : .blue)
                                Image(systemName: "speaker.wave.3.fill").foregroundColor(.gray).font(.caption)
                            }
                            
                            HStack {
                                Text("Alto-falantes da TV").font(.system(.caption, design: .rounded)).foregroundColor(.gray)
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    Button(action: {
                                        isMuted.toggle()
                                        runPythonCommand(args: ["send-key", "KEY_MUTE"])
                                    }) {
                                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(isMuted ? .white : .primary)
                                            .frame(width: 40, height: 40)
                                            .background(isMuted ? Color.red.opacity(0.9) : Color(white: 0.2))
                                            .clipShape(Circle())
                                    }.buttonStyle(HoverBouncyButtonStyle())
                                    
                                    Button(action: {
                                        if isMuted { isMuted = false }
                                        runPythonCommand(args: ["volume-down"])
                                    }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 16, weight: .semibold))
                                            .frame(width: 40, height: 40)
                                            .background(Color(white: 0.2))
                                            .clipShape(Circle())
                                    }.buttonStyle(HoverBouncyButtonStyle())
                                    
                                    Button(action: {
                                        if isMuted { isMuted = false }
                                        runPythonCommand(args: ["volume-up"])
                                    }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 16, weight: .semibold))
                                            .frame(width: 40, height: 40)
                                            .background(Color(white: 0.2))
                                            .clipShape(Circle())
                                    }.buttonStyle(HoverBouncyButtonStyle())
                                }
                            }
                        }
                        .modifier(ModernCardStyle())
                        
                        // 3. CARD DE APLICATIVOS
                        let favoriteApps = allApps.filter { favoriteAppIDs.contains($0.id) }
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Favoritos").font(.system(.headline, design: .rounded))
                            if favoriteApps.isEmpty {
                                Text("Nenhuma aplicação favorita.")
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(favoriteApps) { app in
                                            AppIcon(app: app) {
                                                activeSource = .app(app)
                                                runPythonCommand(args: ["app-run", app.id])
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .modifier(ModernCardStyle())
                        
                        // 4. CARD DE ENTRADAS
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Entradas").font(.system(.headline, design: .rounded))
                            HStack(spacing: 16) {
                                ConsoleCard(title: "PlayStation 5", subtitle: "", port: "HDMI 2", icon: "logo.playstation", imageName: nil, colors: [Color(red: 0.1, green: 0.2, blue: 0.6), Color.black]) {
                                    activeSource = .console(title: "PlayStation 5", icon: "logo.playstation", imageName: nil, color: Color(red: 0.2, green: 0.4, blue: 1.0))
                                    runMacro(keys: ["KEY_SOURCE", "KEY_DOWN", "KEY_ENTER"])
                                }
                                
                                ConsoleCard(title: "Switch 2", subtitle: "", port: "HDMI 1", icon: "gamecontroller.fill", imageName: "nintendo", colors: [Color.red.opacity(0.8), Color.black]) {
                                    activeSource = .console(title: "Switch 2", icon: "gamecontroller.fill", imageName: "nintendo", color: .red)
                                    runMacro(keys: ["KEY_SOURCE", "KEY_DOWN", "KEY_DOWN", "KEY_ENTER"])
                                }
                            }
                        }
                        .modifier(ModernCardStyle())
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                
            } else if currentTab == 1 {
                // ==========================================
                // ABA 1: CONTROLO REMOTO CLÁSSICO
                // ==========================================
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // CARD 1: D-PAD E MÍDIA
                        VStack(spacing: 25) {
                            HStack {
                                Text("Controlo Remoto")
                                    .font(.system(.title2, design: .rounded).weight(.bold))
                                Spacer()
                                Button(action: {
                                    activeSource = .none
                                    runPythonCommand(args: ["send-key", "KEY_POWER"])
                                }) {
                                    Image(systemName: "power")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(Color.red.opacity(0.15))
                                        .clipShape(Circle())
                                }.buttonStyle(HoverBouncyButtonStyle())
                            }
                            .padding(.horizontal)
                            
                            // D-PAD
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.15), Color(white: 0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 230, height: 230)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                    .shadow(color: Color.white.opacity(0.05), radius: 10, x: -5, y: -5)
                                
                                VStack {
                                    Button(action: { runPythonCommand(args: ["send-key", "KEY_UP"]) }) { Image(systemName: "chevron.up").font(.title2.weight(.bold)).frame(width: 60, height: 60) }.buttonStyle(HoverBouncyButtonStyle())
                                    Spacer()
                                    Button(action: { runPythonCommand(args: ["send-key", "KEY_DOWN"]) }) { Image(systemName: "chevron.down").font(.title2.weight(.bold)).frame(width: 60, height: 60) }.buttonStyle(HoverBouncyButtonStyle())
                                }.frame(height: 200)
                                
                                HStack {
                                    Button(action: { runPythonCommand(args: ["send-key", "KEY_LEFT"]) }) { Image(systemName: "chevron.left").font(.title2.weight(.bold)).frame(width: 60, height: 60) }.buttonStyle(HoverBouncyButtonStyle())
                                    Spacer()
                                    Button(action: { runPythonCommand(args: ["send-key", "KEY_RIGHT"]) }) { Image(systemName: "chevron.right").font(.title2.weight(.bold)).frame(width: 60, height: 60) }.buttonStyle(HoverBouncyButtonStyle())
                                }.frame(width: 200)
                                
                                Button(action: { runPythonCommand(args: ["send-key", "KEY_ENTER"]) }) {
                                    ZStack {
                                        Circle().fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 75, height: 75)
                                            .shadow(color: Color.blue.opacity(0.4), radius: 8, y: 4)
                                        Text("OK")
                                            .font(.system(.title3, design: .rounded).weight(.bold))
                                            .foregroundColor(.white)
                                    }
                                }.buttonStyle(HoverBouncyButtonStyle())
                                
                                VStack {
                                    HStack {
                                        Button(action: { runPythonCommand(args: ["send-key", "KEY_HOME"]) }) { Image(systemName: "house.fill").font(.title2).foregroundColor(.gray) }.buttonStyle(HoverBouncyButtonStyle()).offset(x: -25, y: -25)
                                        Spacer()
                                        Button(action: { runPythonCommand(args: ["send-key", "KEY_MENU"]) }) { Image(systemName: "gearshape.fill").font(.title2).foregroundColor(.gray) }.buttonStyle(HoverBouncyButtonStyle()).offset(x: 25, y: -25)
                                    }
                                    Spacer()
                                    HStack {
                                        Button(action: { runPythonCommand(args: ["send-key", "KEY_RETURN"]) }) { Image(systemName: "arrow.uturn.backward").font(.title2).foregroundColor(.gray) }.buttonStyle(HoverBouncyButtonStyle()).offset(x: -25, y: 25)
                                        Spacer()
                                        Button(action: { runPythonCommand(args: ["send-key", "KEY_EXIT"]) }) { Image(systemName: "xmark").font(.title2).foregroundColor(.gray) }.buttonStyle(HoverBouncyButtonStyle()).offset(x: 25, y: 25)
                                    }
                                }.frame(width: 260, height: 260)
                            }
                            .padding(.vertical, 10)
                            
                            // MÍDIA
                            HStack(spacing: 35) {
                                MediaButton(icon: "backward.end.fill") { runPythonCommand(args: ["send-key", "KEY_REWIND"]) }
                                MediaButton(icon: "playpause.fill", isPrimary: true) { runPythonCommand(args: ["send-key", "KEY_PLAY"]) }
                                MediaButton(icon: "forward.end.fill") { runPythonCommand(args: ["send-key", "KEY_FF"]) }
                            }
                        }
                        .modifier(ModernCardStyle())
                        
                        // CARD 2: TRACKPAD
                        TrackpadArea { args in
                            runPythonCommand(args: args)
                        }
                        .modifier(ModernCardStyle())
                        
                        // CARD 3: INPUT DE TEXTO
                        HStack(spacing: 16) {
                            Image(systemName: "keyboard")
                                .foregroundColor(.gray)
                                .font(.title3)
                            
                            TextField("Escrever na TV...", text: $tvTextInput)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color(white: 0.08))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .onSubmit { sendTextToTV() }
                            
                            Button(action: { sendTextToTV() }) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(tvTextInput.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(HoverBouncyButtonStyle())
                            .disabled(tvTextInput.isEmpty)
                        }
                        .modifier(ModernCardStyle())
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                
            } else if currentTab == 2 {
                // ==========================================
                // ABA 2: TODOS OS APLICATIVOS
                // ==========================================
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Todas as Aplicações")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                            ForEach(allApps) { app in
                                VStack {
                                    ZStack(alignment: .topTrailing) {
                                        
                                        AppIcon(app: app) {
                                            activeSource = .app(app)
                                            runPythonCommand(args: ["app-run", app.id])
                                            currentTab = 0
                                        }
                                        
                                        Button(action: {
                                            if favoriteAppIDs.contains(app.id) {
                                                favoriteAppIDs.remove(app.id)
                                            } else {
                                                favoriteAppIDs.insert(app.id)
                                            }
                                        }) {
                                            Image(systemName: favoriteAppIDs.contains(app.id) ? "star.fill" : "star")
                                                .foregroundColor(favoriteAppIDs.contains(app.id) ? .yellow : .white)
                                                .font(.system(size: 12, weight: .bold))
                                                .padding(6)
                                                .background(Circle().fill(Color.black.opacity(0.7)))
                                                .offset(x: 8, y: -8)
                                        }
                                        .buttonStyle(HoverBouncyButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .modifier(ModernCardStyle())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
            } else {
                // ==========================================
                // ABA 3: CONFIGURAÇÕES DA TV
                // ==========================================
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        HStack {
                            Text("Configurações da TV")
                                .font(.system(.title2, design: .rounded).weight(.bold))
                            Spacer()
                            Button(action: { runPythonCommand(args: ["send-key", "KEY_MENU"]) }) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color(white: 0.15))
                                    .clipShape(Circle())
                            }.buttonStyle(HoverBouncyButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        // CARD 1: BRILHO
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sun.max.fill").foregroundColor(.yellow)
                                Text("Brilho da Tela").font(.system(.headline, design: .rounded))
                                Spacer()
                                Text("\(Int(brightness))").font(.system(.title2, design: .rounded).weight(.bold))
                            }
                            
                            HStack {
                                Image(systemName: "sun.min.fill").foregroundColor(.gray).font(.caption)
                                Slider(value: $brightness, in: 0...50, step: 1)
                                    .accentColor(.yellow)
                                Image(systemName: "sun.max.fill").foregroundColor(.gray).font(.caption)
                            }
                        }
                        .modifier(ModernCardStyle())
                        
                        // CARD 2: MODO DE IMAGEM
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Modo de Imagem").font(.system(.headline, design: .rounded))
                            
                            let modes = ["Padrão", "Dinâmico", "Natural", "Filme"]
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(modes, id: \.self) { mode in
                                    Button(action: {
                                        pictureMode = mode
                                        // Ação simulada: envia tecla de menu
                                        runPythonCommand(args: ["send-key", "KEY_MENU"])
                                    }) {
                                        HStack {
                                            Image(systemName: pictureMode == mode ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(pictureMode == mode ? .blue : .gray)
                                            Text(mode)
                                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(pictureMode == mode ? Color.blue.opacity(0.15) : Color(white: 0.12))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(pictureMode == mode ? Color.blue : Color.white.opacity(0.05), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(HoverBouncyButtonStyle())
                                }
                            }
                        }
                        .modifier(ModernCardStyle())
                        
                        // CARD 3: OPÇÕES AVANÇADAS
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Avançado").font(.system(.headline, design: .rounded))
                            
                            Toggle(isOn: $isGameMode) {
                                HStack(spacing: 12) {
                                    Image(systemName: "gamecontroller.fill").foregroundColor(.purple)
                                    Text("Modo Jogo").font(.system(.subheadline, design: .rounded))
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                            .onChange(of: isGameMode) {
                                runPythonCommand(args: ["send-key", "KEY_MENU"])
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.vertical, 4)
                            
                            Button(action: { runPythonCommand(args: ["send-key", "KEY_SLEEP"]) }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "moon.fill").foregroundColor(.indigo)
                                    Text("Timer de Desligamento").font(.system(.subheadline, design: .rounded))
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(HoverBouncyButtonStyle())
                        }
                        .modifier(ModernCardStyle())
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            
        }
        .frame(width: 400, height: 820)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(white: 0.08), Color(white: 0.02)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
        )
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentTab)
    }
    
    // ==========================================
    // FUNÇÕES AUXILIARES
    // ==========================================
    
    func sendTextToTV() {
        guard !tvTextInput.isEmpty else { return }
        runPythonCommand(args: ["send-text", tvTextInput])
        tvTextInput = ""
    }
    
    func runPythonCommand(args: [String]) {
        DispatchQueue.global(qos: .userInitiated).async {
            runPythonCommandSync(args: args)
        }
    }
    
    private func runPythonCommandSync(args: [String]) {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.executableURL = URL(fileURLWithPath: "/path/for/your/project/samsung-tv-remote/.venv/bin/samsungtv")
        
        var fullArgs = ["--host", tvIP, "--token", authToken]
        fullArgs.append(contentsOf: args)
        task.arguments = fullArgs
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Erro: \(error)")
        }
    }
    
    func runMacro(keys: [String]) {
        DispatchQueue.global(qos: .userInitiated).async {
            for key in keys {
                runPythonCommandSync(args: ["send-key", key])
                Thread.sleep(forTimeInterval: 0.6)
            }
        }
    }
}
