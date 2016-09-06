<html>
   <head>
   	<style>
   		.box
			{
				border: 1px solid black;
				height:auto;
				padding:20px;
			}
   	</style>
   </head>
	<body>
   <cfoutput>
   <br>	   
	<h2>There was an error while trying an operation.</h2><br>
	
	Message<br>
	<div class="box">#error.message#</div><br>
	<br>
	Diagnostics:
	<div class="box">#error.diagnostics#</div><br>
	<br>
	Template:
	<div class="box">#error.Template#</div><br>

   <br><br>
	
	Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   
	</cfoutput>
   </body>
</html>