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
        _ accessory: HMAccessory,
        hue: Double,
        saturation: Double = 100,
        brightness: Double = 100,
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
            return
        }

        hueCharacteristic.writeValue(hue) { _ in }
        saturationCharacteristic.writeValue(saturation) { _ in }
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
