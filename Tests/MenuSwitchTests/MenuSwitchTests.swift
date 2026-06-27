import XCTest
@testable import MenuSwitch

final class MenuSwitchTests: XCTestCase {
    func testProxyParsing() throws {
        let json = """
        {
          "proxies": {
            "GLOBAL": {
              "name": "GLOBAL",
              "type": "Selector",
              "now": "ProxyNode",
              "all": ["ProxyNode", "Direct"],
              "history": []
            },
            "ProxyNode": {
              "name": "ProxyNode",
              "type": "Shadowsocks",
              "history": [
                {
                  "time": "2026-06-27T12:00:00Z",
                  "delay": 120
                }
              ]
            }
          }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(MihomoProxiesResponse.self, from: json)
        
        XCTAssertEqual(response.proxies.count, 2)
        
        let global = try XCTUnwrap(response.proxies["GLOBAL"])
        XCTAssertEqual(global.name, "GLOBAL")
        XCTAssertEqual(global.type, "Selector")
        XCTAssertEqual(global.now, "ProxyNode")
        XCTAssertEqual(global.all?.count, 2)
        
        let node = try XCTUnwrap(response.proxies["ProxyNode"])
        XCTAssertEqual(node.name, "ProxyNode")
        XCTAssertEqual(node.type, "Shadowsocks")
        XCTAssertEqual(node.history?.first?.delay, 120)
    }
}
