//
//  HomeKitLightService.swift
//  Mayoty
//
//  Created by sun on 6/5/26.
//

import HomeKit

enum HomeKitLightService {
    static func isLight(_ accessory: HMAccessory) -> Bool {
        accessory.services.contains {
            $0.serviceType == HMServiceTypeLightbulb
        }
    }

    static func setPower(
        _ accessory: HMAccessory,
        isOn: Bool,
        completion: ((Error?) -> Void)? = nil
    ) {
        guard let power = powerCharacteristic(for: accessory) else {
            completion?(HomeKitLightError.powerNotSupported)
            return
        }

        power.writeValue(isOn) { error in
            completion?(error)
        }
    }
    
    static func setColor(
        _ color: HomeKitLightColor,
        accessory: HMAccessory,
        completion: ((Error?) -> Void)? = nil
    ) {
        guard let service = lightService(for: accessory),
              let hueCharacteristic = characteristic(
                in: service,
                type: HMCharacteristicTypeHue
              ),
              let saturationCharacteristic = characteristic(
                in: service,
                type: HMCharacteristicTypeSaturation
              ),
              let brightnessCharacteristic = characteristic(
                in: service,
                type: HMCharacteristicTypeBrightness
              )
        else {
            GameLogger.light("\(accessory.name) 색상 characteristic 찾기 실패")
            completion?(HomeKitLightError.colorNotSupported)
            return
        }

        GameLogger.light("\(accessory.name) 색상 변경 시작: \(color)")

        hueCharacteristic.writeValue(color.hue) { hueError in
            if let hueError {
                GameLogger.light("Hue 변경 실패: \(hueError.localizedDescription)")
                completion?(hueError)
                return
            }

            saturationCharacteristic.writeValue(color.saturation) { saturationError in
                if let saturationError {
                    GameLogger.light("Saturation 변경 실패: \(saturationError.localizedDescription)")
                    completion?(saturationError)
                    return
                }

                brightnessCharacteristic.writeValue(color.brightness) { brightnessError in
                    if let brightnessError {
                        GameLogger.light("Brightness 변경 실패: \(brightnessError.localizedDescription)")
                    } else {
                        GameLogger.light("\(accessory.name) 색상 변경 완료")
                    }

                    completion?(brightnessError)
                }
            }
        }
    }
    
    static func setBrightness(
        _ brightness: Double,
        accessory: HMAccessory,
        completion: ((Error?) -> Void)? = nil
    ) {
        guard let service = lightService(for: accessory),
              let brightnessCharacteristic = characteristic(
                in: service,
                type: HMCharacteristicTypeBrightness
              )
        else {
            completion?(HomeKitLightError.brightnessNotSupported)
            return
        }

        brightnessCharacteristic.writeValue(brightness) { error in
            completion?(error)
        }
    }

    private static func lightService(
        for accessory: HMAccessory
    ) -> HMService? {
        accessory.services.first {
            $0.serviceType == HMServiceTypeLightbulb
        }
    }

    private static func powerCharacteristic(
        for accessory: HMAccessory
    ) -> HMCharacteristic? {
        characteristic(
            in: lightService(for: accessory),
            type: HMCharacteristicTypePowerState
        )
    }

    private static func characteristic(
        in service: HMService?,
        type: String
    ) -> HMCharacteristic? {
        service?.characteristics.first {
            $0.characteristicType == type
        }
    }
}

