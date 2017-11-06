//
//  MainTableViewController.swift
//  DaumBookFinderWithXML
//
//  Created by 이영록 on 2017. 4. 30..
//  Copyright © 2017년 jellyworks. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController, XMLParserDelegate, UISearchBarDelegate {
	let apiKey = "12e019b25265e571f9c178f4d9e4540d"
	var maxPage = 0
	var currentPage = 0
	var books:NSArray?
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		searchBar.delegate = self
     }
	
	func search(page:Int){
		print("Page : \(page)")
		let str = "http://apis.daum.net/search/book?apikey=\(apiKey)&output=json&q=\(searchBar.text!)&pageno=\(page)&result=20" as NSString
		
		let strURL = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
		
		let url = URL(string: strURL!)
		let request = URLRequest(url: url!)
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: dataTaskHandler)
		task.resume()
	}
	
	func dataTaskHandler(data: Data?, response: URLResponse?, error: Error?) {
		if error != nil {return}
		
		do{
			let dic = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
		
			if let channel = dic?["channel"] as? [String:Any], let items = channel["item"] as? NSArray {
				self.books = items
				
				let totalCount = Int(channel["totalCount"] as! String)
				let countPerPage =  Int(channel["result"] as! String)
				if(totalCount! == 0 || countPerPage! == 0 ){
					self.maxPage = 1
				} else {
					self.maxPage  = totalCount! / countPerPage!
				}

				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		} catch {
			print("데이터 수신 실패!")
		}
	}
	
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		currentPage = 1
		search(page: currentPage)
	}
	
	@IBAction func actPrev(_ sender: UIBarButtonItem) {
		if currentPage > 1 {
			currentPage -= 1
			search(page:currentPage)
		}
	}
	
	@IBAction func actNext(_ sender: UIBarButtonItem) {
		if currentPage < maxPage {
			currentPage += 1
			search(page:currentPage)
		}
	}
	
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//		print("items.count = \(items.count)")
		if let books = books {
			return books.count
		} else {
			return  0
		}
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		if let book = books?[indexPath.row] as? [String:String]{
			if let imageView = cell.viewWithTag(1) as? UIImageView
				,let strURL = book["cover_s_url"], let url = URL(string: strURL) {
				do {
					let iData = try Data(contentsOf: url, options: [])
					imageView.image = UIImage(data: iData)
				} catch {}

			}
			
			let lblTitle = cell.viewWithTag(2) as? UILabel
			lblTitle?.text = book["title"]
			
			let lblAuthor = cell.viewWithTag(3) as? UILabel
			lblAuthor?.text = book["author"]
			
			let lblPub = cell.viewWithTag(4) as? UILabel
			lblPub?.text = book["pub_nm"]
			
			let lblPrice = cell.viewWithTag(5) as? UILabel
			lblPrice?.text = book["sale_price"]
		}
		
		
		return cell
    }
	

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let detailViewController = segue.destination as? DetailViewController
			,let indexPath = tableView.indexPathForSelectedRow, let book = books?[indexPath.row] as? [String:String] {
			
			detailViewController.linkURL = book["link"]
		}
    }
	

}
