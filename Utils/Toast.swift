import SwiftUI

struct Toast: View {
    let message: String
    let duration: TimeInterval
    
    @State private var isShowing = false
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)
            .opacity(isShowing ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: isShowing)
            .onAppear {
                isShowing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isShowing = false
                }
            }
    }
    
    static func show(message: String, duration: TimeInterval = 3) {
        let toast = Toast(message: message, duration: duration)
        let hostingView = NSHostingView(rootView: toast)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 50),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.backgroundColor = .clear
        window.isOpaque = false
        window.level = .floating
        window.contentView = hostingView
        window.center()
        
        window.makeKeyAndOrderFront(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            window.close()
        }
    }
}
