//
//  ImageDownloader.swift
//
//
//  Created by Hardik Modha on 15/05/24.
//

import Foundation
import UIKit

public protocol ExternalCaching {
    func save(url: URL, data: Data)
    func load(url: URL) -> Data?
}

actor ImageDownloader {
    
    enum Downloader {
        static func download(url: URL) async throws -> Data {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
    }
    
    enum DownloadState {
        case inProgress(Task<UIImage, Error>)
        case ready(UIImage)
    }
    
    private var externalCache: ExternalCaching?
    private var cache: [URL: DownloadState] = [:]
    
    public func loadImage(url: URL) async throws -> UIImage {
        if let cached = cache[url] {
            switch cached {
            case .inProgress(let task):
                return try await loadInProgress(url: url, task: task)
                
            case .ready(let image):
                return image
            }
        } else if let image = self.externalCashedImage(url: url) {
            return image
        } else {
            let task = Task<UIImage, Error> {
                let data = try await Downloader.download(url: url)
                guard let image = UIImage(data: data) else {
                    struct ImageCoversionError: LocalizedError {
                        var errorDescription: String {
                            "Can not covert UIImage from data."
                        }
                    }
                    throw ImageCoversionError()
                }
                externalCache?.save(url: url, data: data)
                return image
            }
            cache[url] = .inProgress(task)
            
            return try await loadInProgress(url: url, task: task)
        }
    }
    
    public func add(externalCache: ExternalCaching) {
        self.externalCache = externalCache
    }
    
    public func cancel(url: URL) {
        guard case .inProgress(let task) = self.cache[url] else { return }
        task.cancel()
    }
    
    private func loadInProgress(url: URL, task: Task<UIImage, Error>) async throws -> UIImage {
        do {
            let image = try await task.value
            self.cache[url] = .ready(image)
            return image
        } catch {
            self.cache[url] = nil
            throw error
        }
    }
    
    private func externalCashedImage(url: URL) -> UIImage? {
        if let data = self.externalCache?.load(url: url), let image = UIImage(data: data) {
            self.cache[url] = .ready(image)
            return image
        }
        return nil
    }
    
}

enum ImageDownloaderClient {
    static let downloader = ImageDownloader()
}

