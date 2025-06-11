# SVBFinancials

SVBFinancials is a Swift-based iOS app that displays financial data using the Polygon.io API.

---

## Setup Instructions

To run this project locally on your Mac, follow the steps below:

1. **Clone the repository**

   Download the project by cloning the GitHub repository to your Mac. Open Terminal and run:

git clone https://github.com/yourusername/SVBFinancials.git

Once cloned, navigate into the project directory:

cd SVBFinancials

2. **Rename the `secrets.swift.example` file**

Within the project folder, locate the file named `secrets.swift.example` inside the path:

SVB-App/SVB-App/secrets.swift.example

Rename this file to `secrets.swift`. You can do this in Finder or by running the following command in Terminal:

mv SVB-App/SVB-App/secrets.swift.example SVB-App/SVB-App/secrets.swift

3. **Add your Polygon.io API key**

Open the newly renamed `secrets.swift` file in your preferred code editor. Inside the file, you'll see a placeholder line like this:

```swift
let polygonAPIKey = "enter api key here"

Replace the placeholder string with your actual Polygon.io API key. For example:

let polygonAPIKey = "abc123yourapikey"

If you don’t have an API key yet, go to https://polygon.io and sign up for a free account. Note that the free plan allows up to 5 API calls per minute. For more usage or access to additional features, you may need a paid plan.
	4.	Build and run the app
Open the project in Xcode. Once it’s open:
	•	Select a simulator or a connected device from the top device bar.
	•	Press Cmd + R or click the Run button (▶️) in Xcode to build and launch the app.
The app should now be running and fetching financial data via the Polygon.io API.

⸻

Dependencies

This project uses:
	•	Swift
	•	Xcode 14 or later
	•	Polygon.io API

⸻

