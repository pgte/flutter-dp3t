import Flutter
import UIKit
import DP3TSDK

public class SwiftDp3tPlugin: NSObject, FlutterPlugin, DP3TTracingDelegate {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dp3t", binaryMessenger: registrar.messenger())
    let instance = SwiftDp3tPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    var resultValue: Any? = nil
    do {
      switch (call.method) {
        case "getPlatformVersion":
          resultValue = "iOS " + UIDevice.current.systemVersion

        case "reset":
          try _reset()

        case "initializeManually":
          try _initializeManually(call)

        case "initializeWithDiscovery":
          try _initializeWithDiscovery(call)

        case "startTracing":
          try _startTracing()

        case "stopTracing":
          _stopTracing()

        case "status":
          resultValue = _status(call)

        case "iWasExposed":
          resultValue = try _iWasExposed(call)

        default:
          resultValue = FlutterMethodNotImplemented
      }

      result(resultValue)
    } catch {
      result(error)
    }
  }

  public func DP3TTracingStateChanged(_ state: TracingState) {
  }

  func _reset () throws {
    try DP3TTracing.reset()
  }

  func _initializeManually(_ call: FlutterMethodCall) throws {
    let arguments = call.arguments as! Dictionary<String, String?>
    let appId = arguments["appId", default: ""]!
    let bucketBaseUrl = URL(string: arguments["bucketBaseUrl", default: ""]!)!
    let reportBaseUrl = URL(string: arguments["reportBaseUrl", default: ""]!)!
    let jwtPublicKey = (arguments["jwtPublicKey", default: ""] ?? "")!
    let jwtPublicKeyData = Data(base64Encoded: jwtPublicKey)!

    try DP3TTracing.initialize(with: .manual(.init(
      appId: appId,
      bucketBaseUrl: bucketBaseUrl,
      reportBaseUrl: reportBaseUrl,
      jwtPublicKey: jwtPublicKeyData
    )))
    DP3TTracing.delegate = self
  }

  func _initializeWithDiscovery(_ call: FlutterMethodCall) throws {
    let arguments = call.arguments as! Dictionary<String, String?>
    let appId = arguments["appId", default: ""]!
    let environment = arguments["environment", default: "dev"]!

    try DP3TTracing.initialize(with: .discovery(
      appId, enviroment: environment == "dev" ? .dev : .prod))

    DP3TTracing.delegate = self
  }

  func _startTracing() throws {
    DP3TTracing.delegate = self
    try DP3TTracing.startTracing()
  }

  func _stopTracing() {
    DP3TTracing.stopTracing()
  }

  func _status(_ call: FlutterMethodCall) -> Any? {
    var status:Any? = nil
    DP3TTracing.status { result in
      switch result {
      case let .success(state):
        status = _formatStatus(state)
      case let .failure(error):
        status = error
      }
    }

    return status
  }

  func _iWasExposed(_ call: FlutterMethodCall) throws -> Any? {
    let arguments = call.arguments as! Dictionary<String, String>
    let onsetSecondsSince1970String:String = arguments["onset"]!
    let onsetSecondsSince1970 = Double(onsetSecondsSince1970String)
    let onset = Date(timeIntervalSince1970: onsetSecondsSince1970!)
    var throwError: Error? = nil
    var retResult: Any? = nil
    DP3TTracing.iWasExposed(
      onset: onset,
      authentication: .HTTPAuthorizationBearer(token: arguments["authentication"]!)
    ) { result in
      switch result {
        case let .failure(error):
          throwError = error
        case let .success(_result):
          retResult = _result
      }
    }

    if (throwError != nil) {
      throw throwError!
    }

    return retResult
  }

  func _formatStatus(_ state: TracingState) -> [AnyHashable : Any]! {
    var errors: [String] = []
    var nativeErrors: [String] = []
    var nativeErrorArg: Any? = nil
    var tracingState = ""
    switch state.trackingState {
    case .active:
      tracingState = "started"
    case .stopped:
      tracingState = "stopped"
    case let .inactive(error):
      tracingState = "error"
      nativeErrors.append(error.localizedDescription)
      switch error {
      case .bluetoothTurnedOff:
        errors.append("bluetoothDisabled")
      case .permissonError:
        errors.append("permissionMissing")
      case let .caseSynchronizationError(syncError):
        nativeErrorArg = syncError
        errors.append("sync")
    case let .networkingError(netError):
        nativeErrorArg = netError
        errors.append("sync")
      case let .cryptographyError(cError):
        nativeErrorArg = cError
        errors.append("other")
      case let .databaseError(dError):
        nativeErrorArg = dError
        errors.append("other")
      default:
        errors.append("other")
      }
    }

    var healthStatus = ""
    var matchedContacts: [[String : Any]] = []
    var nativeStatusArg: Int? = nil
    switch state.infectionStatus {
    case .healthy:
      healthStatus = "healthy"
    case .infected:
      healthStatus = "infected"
    case let .exposed(days):
      healthStatus = "exposed"
      matchedContacts = days.map { contact in
        return [
          "id": contact.identifier,
          "reportDate": (contact.reportDate.timeIntervalSince1970 * 1000).description
        ]
      }
      nativeStatusArg = days.count
    }

    var res = [
      "tracingState": tracingState,
      "numberOfHandshakes": state.numberOfHandshakes,
      "numberOfContacts": state.numberOfContacts,
      "healthStatus": healthStatus,
      "errors": errors,
      "nativeErrors": nativeErrors,
      "matchedContacts": matchedContacts
    ] as [String : Any]
    if (state.lastSync != nil) {
      res["lastSyncDate"] = (state.lastSync!.timeIntervalSince1970 * 1000).description
    }
    if (nativeErrorArg != nil) {
      res["nativeErrorArg"] = nativeErrorArg
    }
    if (nativeStatusArg != nil) {
      res["nativeStatusArg"] = nativeStatusArg
    }

    return res
  }
}
