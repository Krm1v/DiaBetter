//
//  CreateEmailURL.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 08.08.2023.
//

import UIKit

func createEmailUrl(to: String, subject: String) -> URL? {
	guard let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
		return nil
	}

	let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)")
	let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
	let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)")
	let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)")
	let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)")

	if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
		return gmailUrl
	} else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
		return outlookUrl
	} else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
		return yahooMail
	} else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
		return sparkUrl
	}

	return defaultUrl
}
