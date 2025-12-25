import AVFoundation
final class Speech {
  private let synth = AVSpeechSynthesizer()
  func say(_ s: String, lang: String = "en-US", rate: Float = 0.5) {
    let u = AVSpeechUtterance(string: s)
    u.voice = AVSpeechSynthesisVoice(language: lang)
    u.rate = rate
    synth.speak(u)
  }
}
