# FloraFeed

## My first app using SwiftUI!

---
### What is FloraFeed?

FloraFeed is a prototype app for plant care.

Data on environment variables is received from an IoT device at (hourly) intervals in Firebase.

Four plants with different ideal parameters are mocked (can be modified on the device).

Data is fetched from Firebase and shown using Apple's ChartUI.

System notifications (background fetch) is also implemented.

---
### To improve
- Extend to multiple users (add a user model)
- Ability to add / modify plants. This was outside the scope of the prototype since in reality, this would require multiple IoT devices
- Enable push notifications

---

### References

I used some reference material which is listed below:

- Login using SwiftUI: [Holy swift](https://holyswift.app/how-to-create-a-login-screen-in-swiftui/)
- Table view using SwiftUI: [Medium](https://medium.com/@askvasim/how-to-create-a-table-view-in-swiftui-1e5a20cbf6af)

I also used the Apple and Firebase Swift docs.

