//
//  CellList.swift
//  CySimpleAudio
//
//  Created by Lucy on 10/10/21.
//

import UIKit

class CellList: UITableViewCell {

    @IBOutlet weak var labelArtist: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageAlbum: UIImageView!
    @IBOutlet weak var imagePlaying: UIImageView!

    var isPlaying = false {
        didSet {
            self.imagePlaying.isHidden = !self.isPlaying
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func load(url: URL) {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.imageView?.image = image
                            self?.layoutIfNeeded()
                            self?.setNeedsDisplay()
                        }
                    }
                }
            }
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
