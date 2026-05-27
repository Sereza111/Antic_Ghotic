export type FingerprintCanvasMode = 'original' | 'noise' | 'spoof';
export type FingerprintWebGLMode = 'original' | 'noise' | 'spoof';
export type FingerprintWebRTCMode = 'original' | 'limited' | 'disabled';

export interface FingerprintCanvasConfig {
  mode: FingerprintCanvasMode;
  noiseIntensity?: number; // 0..1 — насколько сильно искажаем картинку
}

export interface FingerprintWebGLConfig {
  mode: FingerprintWebGLMode;
  vendorOverride?: string;
  rendererOverride?: string;
}

export interface FingerprintWebRTCConfig {
  mode: FingerprintWebRTCMode;
}

export interface FingerprintFontsConfig {
  enabled: boolean;
  fontSetId?: string; // логический ID набора шрифтов
}

export interface FingerprintNavigatorConfig {
  userAgent?: string;
  platform?: string;
  hardwareConcurrency?: number;
  deviceMemoryGb?: number;
  doNotTrack?: boolean;
}

export interface FingerprintScreenConfig {
  width?: number;
  height?: number;
  availWidth?: number;
  availHeight?: number;
  colorDepth?: number;
  pixelRatio?: number;
}

export interface FingerprintTimezoneConfig {
  tzOffsetMinutes?: number;
  tzIanaName?: string;
}

export interface FingerprintModulesConfig {
  canvas: FingerprintCanvasConfig;
  webgl: FingerprintWebGLConfig;
  webrtc: FingerprintWebRTCConfig;
  fonts: FingerprintFontsConfig;
  navigator: FingerprintNavigatorConfig;
  screen: FingerprintScreenConfig;
  timezone: FingerprintTimezoneConfig;
}

export interface AutomationSettings {
  scriptIds: string[]; // сценарии, привязанные к профилю
  maxActionsPerRun?: number;
  minDelayMs?: number;
  maxDelayMs?: number;
}

export interface Profile {
  id: string;
  name: string;
  description?: string;

  // базовые данные «виртуального устройства»
  browserEngine: 'chromium' | 'firefox' | 'webkit';
  osFamily: 'windows' | 'macos' | 'linux' | 'android' | 'ios';

  fingerprint: FingerprintModulesConfig;
  automation: AutomationSettings;

  // служебное
  createdAt: string; // ISO
  updatedAt: string; // ISO
  isArchived?: boolean;
}

