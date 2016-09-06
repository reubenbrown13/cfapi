# CFapi
CFML Dynamic API Generator

The purpose of this application is to generate an APIs dynamically at the touch of a button, based upon database views or tables.

CFapi is the perfect companion for open data solutions like CKAN and also great for building mobile applications back-ends.

The result API is prepared for heavy load	consuming. It is based on ETL (Extract, Transform and Load) and anticipated consuming technic, that grabs data from database from time to time and stores it on memory caches, making data available as fast as possible for consumers in a variety of formats, like CSV, REST/JSON, SOAP/WSDL, KML and GeoJSON.

"Anticipated Consuming" is a technic based on a scheduled task that fetches data from database in a regular basis, before there is a remote request asking for data. Imagine that a mobile application user asks for available subway stations in his location. Normally, the mobile application would send a request to some back-end API and then it would query	a database to get that information. This involves reaching the database every time a request is made.

Now imagine that your back-end API has already queried the database. Even BEFORE mobile application user made the request.

Further than that: When the request arrives, the data read from the database is in RAM memory, just waiting to be delivered to the mobile application user after some optional filtering.

This is so fast, it allows real time data to be delivered from the API. We are talking about milliseconds here.

Of course, there is always a trade off. And the drawback here is that the API will probably not support large amounts of data. The idea here is to put a whole table exposed for consuming, so it has to be small sized. For example: bus stops, subway stations, vehicles positions in real time, hospital locations, schools, and so one...

Anyway, this project intends to give Coldfusion/Railo/Lucee developers a tool to instantly deploy an API, made dynamically by the touch of a button.

USAGE:

1) Create one or more database views with the data you want to expose.
2) Create a datasource in Coldfusion Administration connecting to your database.
3) Install CFapi to your developer server.
4) Point your browser to http://localhost/cfapi/index.cfm
5) Fill-in the form fields (API Name, Datasource Name, Database View(s) Name(s), View Name(s) in plural,
	 Search filter fields, Search filter types (string or numeric!), Search filter field sizes, Days in cache, Hours
	 in cache, Minutes in cache).
6) Click on Generate API button.

That´s all!

The system will generate all necessary classes (DTO), methods, memory structures and its access management, CSV, REST and SOAP webServices, all labeled according the information provided on the initial form. Then a zip file will be available to download and deploy to your server, ready to run! CFapi do this by using an API template with terms that are tailored replaced by the information that the user provided in the initial form. 

CFapi comes configured by default to generate an API based on cfbookclub datasource as an example, exposing two tables: authors and books. Just click on the Generate API button to view CFapi in action and then see the result API it generates to understand how it works. 

IMPORTANT:

* Use HTTPS !
* Don´t forget to create a Coldfusion Scheduled Task in Coldfusion Administrator pointing to  
  YourAPI/ScheduledTasks/updateCache.cfm !
* This project uses Mark Mandel's JAVALOADER and Google GSON library.

About REST URL format:

Unfortunately, to keep up with RESTFULL best practices, WEB SERVER URL REWRITING is needed.

Hope you enjoy CFapi!

Feel free to tell your opinion about it.
Thank you,
Luiz Milfont.
