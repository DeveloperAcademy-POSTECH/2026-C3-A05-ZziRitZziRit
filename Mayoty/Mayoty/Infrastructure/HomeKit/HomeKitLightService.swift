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
            return
        }

        hueCharacteristic.writeValue(color.hue) { _ in }
        saturationCharacteristic.writeValue(color.saturation) { _ in }
        brightnessCharacteristic.writeValue(color.brightness) { error in
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
