/* UIKit Tools - command-line utilities for UIKit
 * Copyright (C) 2008-2012  Jay Freeman (saurik)
*/

/* Modified BSD License {{{ */
/*
 *        Redistribution and use in source and binary
 * forms, with or without modification, are permitted
 * provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the
 *    above copyright notice, this list of conditions
 *    and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the
 *    above copyright notice, this list of conditions
 *    and the following disclaimer in the documentation
 *    and/or other materials provided with the
 *    distribution.
 * 3. The name of the author may not be used to endorse
 *    or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
 * BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/* }}} */

#import <UIKit/UIKit.h>
#include <stdio.h>
#include <dlfcn.h>
#include <objc/runtime.h>

static CFArrayRef (*$GSSystemCopyCapability)(CFStringRef);
static CFArrayRef (*$GSSystemGetCapability)(CFStringRef);

void OnGSCapabilityChanged(
    CFNotificationCenterRef center,
    void *observer,
    CFStringRef name,
    const void *object,
    CFDictionaryRef info
) {
    CFRunLoopStop(CFRunLoopGetCurrent());
}

int main(int argc, char *argv[]) {
    dlopen("/System/Library/Frameworks/Foundation.framework/Foundation", RTLD_GLOBAL | RTLD_LAZY);
    dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_GLOBAL | RTLD_LAZY);

    NSAutoreleasePool *pool = [[objc_getClass("NSAutoreleasePool") alloc] init];

    NSString *name = nil;

    if (argc == 2)
        name = [objc_getClass("NSString") stringWithUTF8String:argv[0]];
    else if (argc > 2) {
        fprintf(stderr, "usage: %s [capability]\n", argv[0]);
        exit(1);
    }

    $GSSystemCopyCapability = reinterpret_cast<CFArrayRef (*)(CFStringRef)>(dlsym(RTLD_DEFAULT, "GSSystemCopyCapability"));
    $GSSystemGetCapability = reinterpret_cast<CFArrayRef (*)(CFStringRef)>(dlsym(RTLD_DEFAULT, "GSSystemGetCapability"));

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        &OnGSCapabilityChanged,
        CFSTR("GSCapabilitiesChanged"),
        NULL,
        0
    );

    for (;;) {
        const NSDictionary *capability;

        if ($GSSystemCopyCapability != NULL) {
            capability = reinterpret_cast<const NSDictionary *>((*$GSSystemCopyCapability)(reinterpret_cast<CFStringRef>(name)));
            if (capability != nil)
                capability = [capability autorelease];
        } else if ($GSSystemGetCapability != NULL) {
            capability = reinterpret_cast<const NSDictionary *>((*$GSSystemGetCapability)(reinterpret_cast<CFStringRef>(name)));
        } else {
            capability = nil;

            if (void *libMobileGestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY))
                if (CFTypeRef (*$MGCopyAnswer)(CFStringRef) = reinterpret_cast<CFTypeRef (*)(CFStringRef)>(dlsym(libMobileGestalt, "MGCopyAnswer"))) {
                    NSMutableDictionary *answers([NSMutableDictionary dictionary]);
                    for (NSString *name in [NSArray arrayWithObjects:
                        @"HasSEP",
                        @"HasThinBezel",
                        @"apple-internal-install",
                        @"cameraRestriction",
                        @"data-plan",
                        @"multitasking-gestures",
                        @"rear-facing-camera",
                        @"wapi",
                        @"watch-companion",

                        @"AirDropCapability",
                        @"CarrierInstallCapability",
                        @"CellularTelephonyCapability",
                        @"UIParallaxCapability",
                        @"ambient-light-sensor",
                        @"personal-hotspot",
                        @"shoebox",
                        @"hall-effect-sensor",
                        @"3Gvenice",

                        @"ActiveWirelessTechnology",
                        //@"AirplaneMode",
                        @"AllDeviceCapabilities",
                        @"AllowYouTube",
                        @"AllowYouTubePlugin",
                        //@"ApNonce",
                        //@"AppleInternalInstallCapability",
                        @"assistant",
                        //@"BasebandBoardSnum",
                        //@"BasebandCertId",
                        //@"BasebandChipId",
                        //@"BasebandFirmwareManifestData",
                        @"BasebandFirmwareVersion",
                        //@"BasebandKeyHashInformation",
                        //@"BasebandRegionSKU",
                        //@"BasebandSerialNumber",
                        @"BatteryCurrentCapacity",
                        @"BatteryIsCharging",
                        @"BatteryIsFullyCharged",
                        //@"BluetoothAddress",
                        @"BoardId",
                        @"BuildVersion",
                        @"CPUArchitecture",
                        //@"CarrierBundleInfoArray",
                        @"CarrierInstallCapability",
                        @"cellular-data",
                        @"ChipID",
                        //@"CompassCalibration",
                        //@"CompassCalibrationDictionary",
                        //@"ComputerName",
                        @"contains-cellular-radio",
                        @"DeviceClass",
                        @"DeviceClassNumber",
                        @"DeviceColor",
                        @"DeviceEnclosureColor",
                        //@"DeviceName",
                        @"DeviceSupports1080p",
                        @"DeviceSupports3DImagery",
                        @"DeviceSupports3DMaps",
                        @"DeviceSupports4G",
                        @"DeviceSupports720p",
                        @"DeviceSupports9Pin",
                        @"DeviceSupportsFaceTime",
                        @"DeviceSupportsLineIn",
                        @"DeviceSupportsNavigation",
                        @"DeviceSupportsSimplisticRoadMesh",
                        @"DeviceSupportsTethering",
                        @"DeviceVariant",
                        //@"DiagData",
                        @"dictation",
                        //@"DieId",
                        //@"DiskUsage",
                        @"encrypted-data-partition",
                        //@"EthernetMacAddress",
                        @"ExternalChargeCapability",
                        @"ExternalPowerSourceConnected",
                        //@"FaceTimeBitRate2G",
                        //@"FaceTimeBitRate3G",
                        //@"FaceTimeBitRateLTE",
                        //@"FaceTimeBitRateWiFi",
                        //@"FaceTimeDecodings",
                        //@"FaceTimeEncodings",
                        //@"FaceTimePreferredDecoding",
                        //@"FaceTimePreferredEncoding",
                        //@"FirmwareNonce",
                        //@"FirmwarePreflightInfo",
                        @"FirmwareVersion",
                        @"ForwardCameraCapability",
                        @"gps",
                        @"green-tea",
                        @"HWModelStr",
                        @"HardwarePlatform",
                        //@"HasAllFeaturesCapability",
                        @"HasBaseband",
                        @"HasInternalSettingsBundle",
                        @"HasSpringBoard",
                        //@"IntegratedCircuitCardIdentifier",
                        //@"InternalBuild",
                        //@"InternationalMobileEquipmentIdentity",
                        //@"InverseDeviceID",
                        //@"IsSimulator",
                        //@"IsThereEnoughBatteryLevelForSoftwareUpdate",
                        //@"IsUIBuild",
                        //@"MLBSerialNumber",
                        @"main-screen-class",
                        @"main-screen-height",
                        @"main-screen-orientation",
                        @"main-screen-pitch",
                        @"main-screen-scale",
                        @"main-screen-width",
                        @"MinimumSupportediTunesVersion",
                        //@"MobileEquipmentIdentifier",
                        //@"MobileSubscriberCountryCode",
                        //@"MobileSubscriberNetworkCode",
                        @"wi-fi",
                        @"ModelNumber",
                        @"not-green-tea",
                        @"PanoramaCameraCapability",
                        @"PartitionType",
                        @"ProductName",
                        @"ProductType",
                        @"ProductVersion",
                        //@"ProximitySensorCalibration",
                        @"RearCameraCapability",
                        @"RegionCode",
                        @"RegionInfo",
                        //@"RegionalBehaviorAll",
                        @"RegionalBehaviorChinaBrick",
                        @"RegionalBehaviorEUVolumeLimit",
                        @"RegionalBehaviorGB18030",
                        @"RegionalBehaviorGoogleMail",
                        @"RegionalBehaviorNTSC",
                        @"RegionalBehaviorNoPasscodeLocationTiles",
                        @"RegionalBehaviorNoVOIP",
                        @"RegionalBehaviorNoWiFi",
                        @"RegionalBehaviorShutterClick",
                        @"RegionalBehaviorVolumeLimit",
                        @"RegulatoryIdentifiers",
                        //@"ReleaseType",
                        @"RequiredBatteryLevelForSoftwareUpdate",
                        @"SBAllowSensitiveUI",
                        @"SBCanForceDebuggingInfo",
                        @"SDIOManufacturerTuple",
                        @"SDIOProductInfo",
                        //@"SIMTrayStatus",
                        //@"ScreenDimensions",
                        //@"screen-dimensions",
                        //@"SerialNumber",
                        @"ShouldHactivate",
                        @"SigningFuse",
                        //@"SoftwareBehavior",
                        //@"SoftwareBundleVersion",
                        @"SupportedDeviceFamilies",
                        //@"SupportedKeyboards",
                        //@"SysCfg",
                        //@"UniqueChipID",
                        //@"UniqueDeviceID",
                        //@"UniqueDeviceIDData",
                        //@"UserAssignedDeviceName",
                        //@"WifiAddress",
                        //@"WifiAddressData",
                        //@"WifiVendor",
                        //@"WirelessBoardSnum",
                        @"iTunesFamilyID",

                        @"720p",
                        @"1080p",
                        @"accelerometer",
                        @"accessibility",
                        @"additional-text-tones",
                        @"all-features",
                        @"any-telephony",
                        @"app-store",
                        @"application-installation",
                        @"armv6",
                        @"armv7",
                        @"assistant",
                        @"auto-focus-camera",
                        @"bluetooth",
                        @"bluetooth-le",
                        @"camera-flash",
                        @"cellular-data",
                        @"contains-cellular-radio",
                        @"dictation",
                        @"display-mirroring",
                        @"displayport",
                        @"encode-aac",
                        @"encrypted-data-partition",
                        @"fcc-logos-via-software",
                        @"front-facing-camera",
                        @"gamekit",
                        @"gas-gauge-battery",
                        @"gps",
                        @"gyroscope",
                        @"h264-encoder",
                        @"hardware-keyboard",
                        @"hd-video-capture",
                        @"hdr-image-capture",
                        @"hiccough-interval",
                        @"hidpi",
                        @"homescreen-wallpaper",
                        @"hw-encode-snapshots",
                        @"international-settings",
                        @"io-surface-backed-images",
                        @"load-thumbnails-while-scrolling",
                        @"location-services",
                        @"magnetometer",
                        @"microphone",
                        @"mms",
                        @"multitasking",
                        @"music-store",
                        @"nike-ipod",
                        @"not-green-tea",
                        @"opengles-1",
                        @"opengles-2",
                        @"peer-peer",
                        @"photo-adjustments",
                        @"photo-stream",
                        @"proximity-sensor",
                        @"ptp-large-files",
                        @"ringer-switch",
                        @"sms",
                        @"stand-alone-contacts",
                        @"still-camera",
                        @"telephony",
                        @"telephony-maximum-generation",
                        @"tv-out-crossfade",
                        @"tv-out-settings",
                        @"unified-ipod",
                        @"venice",
                        @"video-camera",
                        @"voice-control",
                        @"voip",
                        @"volume-buttons",
                        @"wifi",
                        @"youtube",
                        @"youtube-plugin",
                        @"ipad",
                        @"wildcat",
                    nil])
                        if (CFTypeRef answer = $MGCopyAnswer(reinterpret_cast<CFStringRef>(name))) {
                            [answers setObject:(id)answer forKey:name];
                            CFRelease(answer);
                        }
                    capability = answers;
                }
        }

        if (capability != nil) {
            printf("%s\n", capability == nil ? "(null)" : [[capability description] UTF8String]);
            break;
        }

        CFRunLoopRun();
    }

    [pool release];

    return 0;
}
