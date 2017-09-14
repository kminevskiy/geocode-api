### How to use:

- Install Ruby (probably comes with your OS)
- "cd" into the script directory
- Install bundler (gem install bundler)
- Execute "bundle install" to install dependencies
- Run the script
- To run RSpec tests, execute "rspec"

#### Overview:

First, we want to make sure that we received everything we need from a user - the address and/or zip code. This is handled by a separate module.


Second, the script parses the .csv file using the standard Ruby library CSV module. It then relies on another component to make an HTTP request to Google geocode API and parses returned data. Then we iterate over the contents of the file, calculating distance difference for each row of data. If the distance for the new row of data is less than the previous one, we save that information. At the end we output the result to the user based on the specified (or default) output format.


My goal was to make the application open to potential functional extensions and, at the same time, keep each component isolated from other parts of the system. This way if we need to add functionality we'll simply add new entities without remodeling our current system. Because each component doesn't need to know about the implementation details of other parts of the system, we can modify each piece separately and still maintain a working API.


Last, I tested basic functionality of the application. I haven't dived really deep into private methods testing (which is usually discouraged). Instead, I made several assumptions about the desired output.

Also, I thought it might be a bad idea to keep querying Google's API every time we run our tests. And to avoid that I mocked/stubbed all subsequent HTTP requests (only 1 is made at the beginning). This is usually a good idea if we can make an assumption that once we receive the data it will stay the same (I think we can make that assumption since the address probably won't change in a matter of minutes).

#### Assumptions:

- **Throttling**. Current implementation is probably not suitable for a high-traffic endpoint - Google will aggressively rate-limit / throttle unrestrained HTTP requests. If it's a business-critical component, more research is required. 

* Potential solution: discuss potential endpoint throughput and make a decision based on that.

- **Large input files**. With relatively small files (like the one provided) it's probably OK to parse the file every time someone hits this endpoint. However, if the file size is large and requests are frequent, it might make sense to introduce a caching layer. We may want to cache frequently requested stores (maybe the most popular / largest brands / etc) and then, on new request, hit the cache layer first and if there's a cache miss hit the file.

* Potential solution: think about the size of file (will it stay the same or will it grow?). Based on that think about caching frequently requested data.

- **Dependencies**. I tried to minimize external library dependencies (there's only 1 pretty established and mature module called HTTP). External dependencies introduce new assumptions about certain parts of the system. If the module's API changes at some point in the future, the application will brake. The more dependencies we have, the more fragile our codebase becomes. That's why I used only 1 library (which can be removed and application's code refactored if there's such requirement).

* Potential solution: keep code simple and implement new features only when explicitly required.