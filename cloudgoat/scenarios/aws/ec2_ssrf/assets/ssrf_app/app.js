const needle = require('needle');
const express = require('express');
const url = require('url');
const app = express();
const port = 80;

// Whitelist of allowed domains to prevent SSRF
const allowedDomains = ['example.com', 'another-safe-domain.com'];

app.get('/', function (request, response) {
  const inputUrl = request.query['url'];
  let mime = request.query['mime'] === 'plain' ? 'plain' : 'html';

  console.log('New request: ' + request.url);

  // If the URL is not set, then return the default page.
  if (!inputUrl) {
    response.writeHead(200, { 'Content-Type': 'text/' + mime });
    response.write('<h1>Welcome to sethsec\'s SSRF demo.</h1>\n\n');
    response.write('<h2>I am an application. I want to be useful, so give me a URL to request for you\n</h2><br><br>\n\n\n');
    response.end();
  } else {
    // Parse and validate the input URL
    const parsedUrl = url.parse(inputUrl);
    if (!allowedDomains.includes(parsedUrl.hostname)) {
      response.status(400).send('Invalid URL domain');
      return;
    }

    // Make request to the validated URL
    needle.get(inputUrl, { timeout: 3000 }, function (error, response1) {
      if (!error && response1.statusCode === 200) {
        response.writeHead(200, { 'Content-Type': 'text/' + mime });
        response.write('<h1>Welcome to sethsec\'s SSRF demo.</h1>\n\n');
        response.write('<h2>I am an application. I requested a URL for you.</h2><br><br>\n\n\n');
        response.write(response1.body);
        response.end();
      } else {
        response.writeHead(404, { 'Content-Type': 'text/' + mime });
        response.write('<h1>Welcome to sethsec\'s SSRF demo.</h1>\n\n');
        response.write('<h2>I wanted to be useful, but I could not find the requested URL.</h2><br><br>\n\n\n');
        response.end();
        console.log(error);
      }
    });
  }
});

app.listen(port);
console.log('\n##################################################')
console.log('#\n#  Server listening for connections on port:' + port);
console.log('#  Connect to server using the following url: \n#  -- http://server:' + port + '/?url=SSRF URL');
console.log('#\n##################################################');