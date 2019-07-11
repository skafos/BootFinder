//
//  ResultsDisplayViewController.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/5/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import UIKit
import SafariServices

class ResultsDisplayViewController: DismissingModalViewController {
  static func build(bootFinder: BootFinder, indices: [Int], onDismiss: (() -> ())?) -> ResultsDisplayViewController? {
    let storyboard = UIStoryboard(name: "Main", bundle: .main)
    let id = "ResultsDisplayViewController"
    let vc = storyboard.instantiateViewController(withIdentifier: id) as? ResultsDisplayViewController
    vc?.bootFinder = bootFinder
    vc?.indices = indices
    vc?.onDismiss = onDismiss
    return vc
  }

  private var bootFinder: BootFinder!
  private var indices: [Int] = []

  @IBOutlet var headerLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    setHeaderLabel()
  }

  func setHeaderLabel() {
    let formatString = NSLocalizedString("%d Similar Boots found", comment: "Results page header label format string")
    headerLabel.text = String(format: formatString, indices.count)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

extension ResultsDisplayViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return indices.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsDisplayCell", for: indexPath) as! ResultsDisplayCell
    cell.presenter = self
    cell.setBoot(bootFinder.boot(at: indices[indexPath.row]))
    return cell
  }
}

class ResultsDisplayCell: UITableViewCell {
  @IBOutlet var bootImageView: UIImageView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var subtitleLabel: UILabel!
  @IBOutlet var priceLabel: UILabel!

  var boot: Boot?
  unowned var presenter: UIViewController?
  var imageTask: URLSessionDataTask?

  func setBoot(_ boot: Boot?) {
    guard let boot = boot else {
      return
    }
    self.boot = boot
    titleLabel.text = boot.name
    subtitleLabel.text = boot.brand
    priceLabel.text = boot.price
    downloadImage()
  }

  @IBAction func buyBoot(_ sender: Any) {
    guard
      let urlString = boot?.buyURLString,
      let url = URL(string: urlString),
      ["http", "https"].contains(url.scheme)
    else {
      return
    }
    let browser = SFSafariViewController(url: url)
    presenter?.present(browser, animated: true, completion: nil)
  }

  func downloadImage() {
    guard
      let boot = self.boot,
      let imageURL = URL(string: boot.imageURLString)
    else {
        return
    }

    cancelImageDownload()
    let setImage: (Data?, URLResponse?, Error?) -> () = { [weak self] data, _, _ in
      DispatchQueue.main.async {
        guard let data = data, boot == self?.boot else {
          return
        }
        self?.bootImageView.image = UIImage(data: data)
      }
    }
    imageTask = URLSession.shared.dataTask(with: imageURL, completionHandler: setImage)
    imageTask?.resume()
  }

  func cancelImageDownload() {
    imageTask?.cancel()
    imageTask = nil
  }

  override func prepareForReuse() {
    cancelImageDownload()
    boot = nil
  }
}
