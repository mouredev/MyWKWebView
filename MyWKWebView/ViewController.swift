//
//  ViewController.swift
//  MyWKWebView
//
//  Created by Brais Moure on 12/8/18.
//  Copyright © 2018 Brais Moure. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    // MARK: - Private
    private let searchBar = UISearchBar()
    private var webView: WKWebView!
    private let refreshControl = UIRefreshControl()
    private let baseUrl = "http://www.google.com"
    private let searchPath = "/search?q="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation buttons
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        
        // Search bar
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        // Web view
        let webViewPrefs = WKPreferences()
        webViewPrefs.javaScriptEnabled = true
        webViewPrefs.javaScriptCanOpenWindowsAutomatically = true
        let webViewConf = WKWebViewConfiguration()
        webViewConf.preferences = webViewPrefs
        webView = WKWebView(frame: view.frame, configuration: webViewConf)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.keyboardDismissMode = .onDrag
        view.addSubview(webView)
        webView.navigationDelegate = self
        
        // Refresh control
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        view.bringSubview(toFront: refreshControl)
        
        // Load url
        load(url: baseUrl)
    }

    @IBAction func backButtonAction(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        webView.goForward()
    }
    
    // MARK: - Private methods
    
    private func load(url: String) {
        
        var urlToLoad: URL!
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            urlToLoad = url
        } else {
            urlToLoad = URL(string: "\(baseUrl)\(searchPath)\(url)")!
        }
        webView.load(URLRequest(url: urlToLoad))
    }
    
    @objc private func reload() {
        webView.reload()
    }
    
}

// MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        load(url: searchBar.text ?? "")
    }
    
}

// MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate {
    
    // Finish
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        refreshControl.endRefreshing()
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        view.bringSubview(toFront: refreshControl)
    }
    
    // Start
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        refreshControl.beginRefreshing()
        searchBar.text = webView.url?.absoluteString
    }
    
    // Error
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        refreshControl.beginRefreshing()
        view.bringSubview(toFront: refreshControl)
    }
    
}

