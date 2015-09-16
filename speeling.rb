require "webrick"

class Dictionary < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    words = File.readlines("my_dict.txt")
    words.sort!

    response.status = 200
    response.body = %(
    <html>
      <head>
        <title>The Urban Urban Dictionary</title>
        <style>
          h1 {
              text-align:center
             }
          h3 {
              text-align:center
             }
          p  {
             padding-left: 20px;
             font-size: 24px
             }
          a:visited {
              color: blue;
             }
        </style>
      </head>
      <body>
        <h1>Welome to The Urban Urban Dictionary</h1>
        <h3>'Your Dictionary the way you want it!'</h3>
        <div>
          <form method="GET" action="/search">
          Looking for a word?
            <input name = "search">
            <button type="submit">SHOW ME</button>
          </form>
        </div>
        <div>
          Don't see a word here? <a href="/add">ADD</a> it to make this site better!
        </div>
          <p>
            #{words.join("<br/>")}
          </p>
      </body>
    </html>
    )
  end
end

class AddWord < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)

    response.status = 200
    response.body = %(
    <html>
      <head>
      <title>The Urban Urban Dictionary</title>
      </head>
      <body>
        <h1>Thank you for your contribution!</h1>
        <form method="POST" action="/save">
          <input name = "word">
          <button type="submit">ADD</button>
        </form>
      </body>
    </html>
    )
  end
end

class SaveWord < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    File.open("my_dict.txt", "a+") do |input|
      input.puts "#{request.query["word"]}"
    end

    response.status = 302
    response.header["Location"] = "/"
    response.body = "Saved"
  end
end

class SearchWord < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    lines = File.open("my_dict.txt")
      chomped = lines.map do |line|
        line.chomp
      end
      found = chomped.select do |match|
        match == request.query["search"]
      end

    response.status = 200
    response.body = %(
    <html>
    <head>
      <title>...and ye shall receive.</title>
    </head>
    <body>
    <a href="/">BACK HOME</a>
      <h3>I've found your words!</h3>
      #{found[0]}
    </body>
    </html>
    )
  end
end

server = WEBrick::HTTPServer.new(Port:3027)
server.mount "/", Dictionary
server.mount "/add", AddWord
server.mount "/save", SaveWord
server.mount "/search", SearchWord
trap("INT") { server.shutdown }

server.start
