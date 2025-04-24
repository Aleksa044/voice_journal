//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audioplayers
import path_provider_foundation
import record_darwin
import shared_preferences_foundation
import speech_to_text

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioplayersPlugin.register(with: registry.registrar(forPlugin: "AudioplayersPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  RecordPlugin.register(with: registry.registrar(forPlugin: "RecordPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SpeechToTextPlugin.register(with: registry.registrar(forPlugin: "SpeechToTextPlugin"))
}
