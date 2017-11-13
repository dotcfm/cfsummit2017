<cfscript>

  hostname = CreateObject("java","java.net.InetAddress").getLocalHost().getHostName();
  whale_pos = RandRange(0,90);

</cfscript>

<cflog text="Whale Position: #whale_pos#">

<cfoutput>
  <h1>Demo 1</h1>
  <h2>Container: #hostname#</h2>
  <a href=".">refresh</a><br><br>
  <img src="docker.png" height="100" width="100" style="margin-left: #whale_pos#%;">
  <h2>Whale Position: #whale_pos#</h2>
</cfoutput>