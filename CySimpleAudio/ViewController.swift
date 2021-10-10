//
//  ViewController.swift
//  CySimpleAudio
//
//  Created by Lucy on 08/10/21.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {
    let strClientID = "21ce98fbb8cb43468ab444e8c3016e96"
    let strClientSecret = "39e1ca56fcaf4ca4858745bab1b63318"
    let strKeyExp = "expires_in"
    let strKeyToken = "access_token"
    let strKeyTimeToken = "time_retrieved"
    var intIndexActive = -1
    @IBOutlet weak var labelTitleNow: UILabel!
    @IBOutlet weak var buttonStop: UIButton!
    /*Client ID 21ce98fbb8cb43468ab444e8c3016e96
     Client Secret 39e1ca56fcaf4ca4858745bab1b63318 */
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var textFieldSearch: UITextField!
    var avPlayer: AVPlayer!

    var modelData: ModelTracks?
    var modelList: [ModelAudio]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.textFieldSearch.delegate = self
        if self.isTokenExpired() {
            self.serviceCallToken()
        }
        self.labelTitleNow.text = "Not Playing"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.doStop(self)
    }

    deinit {

    }

    private func setupTableView() {
        let nibToRegister = UINib(nibName: String(describing: CellList.self), bundle: nil)
        tableList.register(nibToRegister, forCellReuseIdentifier: String(describing: CellList.self))

        tableList.delegate = self
        tableList.dataSource = self
        tableList.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableList.separatorInset = .zero
    }

    func serviceCallToken(){
        let spotifyAuthKey = "Basic \((strClientID + ":" + strClientSecret).data(using: .utf8)!.base64EncodedString())"
        let requestHeaders: [String:String] = [ "Authorization" : spotifyAuthKey,
                                                "Content-Type" : "application/x-www-form-urlencoded"]
        var requestBody = URLComponents()
        requestBody.queryItems = [
            URLQueryItem(name: "grant_type", value: "client_credentials"),

        ]

        var request = URLRequest(url:URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBody.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: request){ (data, response, error) in
            print("RESPONSE", response)
            if let data = data {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    UserDefaults.standard.set(jsonResult?.object(forKey:self.strKeyExp), forKey: self.strKeyExp)
                    UserDefaults.standard.set(jsonResult?.object(forKey: self.strKeyToken), forKey: self.strKeyToken)
                    UserDefaults.standard.set(Date(), forKey: self.strKeyTimeToken)
                    print("RESULT",jsonResult)

                } catch {
                    print(error)
                }

                // Reload table view
                OperationQueue.main.addOperation {

                }
            }

        }.resume()
    }

    func isTokenExpired() -> Bool {
        var isExpired = true

        if let dateReceived = UserDefaults.standard.object(forKey: strKeyTimeToken) as? Date {
            if let timeExpire = UserDefaults.standard.object(forKey: strKeyExp) as? Int {
                let dateExpired = dateReceived.addingTimeInterval(Double(timeExpire))
                let dateNow = Date()
                if dateNow < dateExpired {
                    isExpired = false
                }
            }
        }
        return isExpired
    }

    @IBAction func textFieldSearchValueChanged(_ sender: Any) {
        print("TEXTFieldChanghed", self.textFieldSearch.text)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
        self.perform(#selector(self.reload), with: nil, afterDelay: 0.5)
    }

    @IBAction func doStop(_ sender: Any) {
        if let _ = self.avPlayer {
            self.avPlayer.pause()

            self.avPlayer = nil
            print("player deallocated")
            self.labelTitleNow.text = "Not Playing"
        }
    }

    func doPlay(str: String) {
        print("Play",str)
        self.avPlayer = AVPlayer(url: URL(string: str)!)
        self.avPlayer.play()
    }
}

extension ViewController: UITextFieldDelegate {

}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let data = self.modelList {
            if data.count > 0 {
                count = data.count
            }
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CellList.self)) as! CellList
        if let model = self.modelList {
            if let str = model[indexPath.row].name {
                cell.labelTitle.text = str
            }

            if let str = model[indexPath.row].artists?.first?.name {
                cell.labelArtist.text = str
            }

            if let str = model[indexPath.row].album?.images?.last?.url {
                print("IMAGE URL", str)
                cell.load(url: URL(string: str)!)
            }

            if self.intIndexActive >= 0 {
                if self.intIndexActive == indexPath.row {
                    cell.isPlaying = true
                } else {
                    cell.isPlaying = false
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.doStop(self)
        if let activeData = self.modelList?[indexPath.row] {
            self.labelTitleNow.text = activeData.name
            self.doPlay(str: activeData.preview_url!)
            self.intIndexActive = indexPath.row
            self.tableList.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

extension ViewController {

    @objc func reload() {
        if let strSearch = self.textFieldSearch.text {
            if let strToken = UserDefaults.standard.object(forKey: strKeyToken) as? String {
                let strParamQuery = "q=\(strSearch.replacingOccurrences(of: " ", with: "%20"))"
                print("SEARCH", strParamQuery)
                let requestHeaders: [String:String] = ["Authorization" : "Bearer " + strToken]

                var request = URLRequest(url:URL(string: "https://api.spotify.com/v1/search?\(strParamQuery)&type=track&limit=30")!)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = requestHeaders

                URLSession.shared.dataTask(with: request){ (data, response, error) in

                    if let data = data {

                        let decoder = JSONDecoder()
                        do {
                            self.modelData = try decoder.decode(ModelTracks.self, from: data)
                            if let model = self.modelData {
                                if let modelT = model.tracks {
                                    if let modelI = modelT.items {
                                        self.modelList = modelI.filter{ $0.preview_url != nil }
                                    }
                                }
                            }

                            print("MODEList", self.modelList!)
                        } catch {
                            print(error)
                        }

                        // Reload table view
                        OperationQueue.main.addOperation {
                            self.tableList.reloadData()
                        }
                    }
                    /*if let data = data {
                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                            if let tracks = jsonResult?.object(forKey: "tracks") as? NSDictionary {
                                if let item = tracks.object(forKey: "items") as? NSDictionary {
                                    if let artist = item.object(forKey: "album") as? NSDictionary {

                                    }
                                }
                            }
                            //print("RESULT",jsonResult)

                        } catch {
                            print(error)
                        }

                        // Reload table view
                        OperationQueue.main.addOperation {

                        }
                    }*/

                }.resume()
            }        }


    }
}
