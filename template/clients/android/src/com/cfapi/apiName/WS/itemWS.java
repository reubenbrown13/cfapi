//
// REST WebService consumer

package com.cfapi.[[*apiName*]].WS;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.net.Uri;
import android.util.Log;
import com.cfapi.[[*apiName*]].DTO.[[*viewNameUC*]]DTO;

public class [[*viewNameUC*]]WS
{

   private static String URL="";
   private static String ENDPOINT="";
   private static int timeout=10000;

   public ArrayList<[[*viewNameUC*]]DTO> get[[*viewNameUC*]]List(String token)
   {
      URL="http://[[*endPointDomain*]]";
      ENDPOINT="/[[*apiName*]]/api/v1/rest/[[*pluralViewName*]].cfm";

      ArrayList<[[*viewNameUC*]]DTO> [[*viewNameLC*]]List=new ArrayList<[[*viewNameUC*]]DTO>();
      String result="";

      try
      {
         HttpParams httpParameters=new BasicHttpParams();
         int timeoutConnection=timeout;
         HttpConnectionParams.setConnectionTimeout(httpParameters, timeoutConnection);
         int timeoutSocket=timeout;
         HttpConnectionParams.setSoTimeout(httpParameters, timeoutSocket);

         // Define inputStream
         InputStream inputStream=null;

         // Create http client.
         HttpClient httpclient=new DefaultHttpClient(httpParameters);

         // Define input parameters values.
         Uri.Builder b=Uri.parse(URL).buildUpon();
         b.path(ENDPOINT);
         b.appendQueryParameter("token", token);
         b.appendQueryParameter("pretty", "");
         b.appendQueryParameter("filter", "");
         String url=b.build().toString();

         // Create the GET and set URL.
         HttpGet httpget=new HttpGet(url);

         // Define data type.
         httpget.setHeader("Accept", "text/json");

         try
         {
            // Send the URL request, using GET.
            HttpResponse httpResponse=httpclient.execute(httpget);

            // Receive response as "inputStream".
            inputStream=httpResponse.getEntity().getContent();

            String converted=convertInputStreamToString(inputStream);

            // Check if http response code is 200 (OK).
            if (httpResponse.getStatusLine().getStatusCode() == 200)
            {
               result=converted;

               // Parse JSON.
               [[*viewNameLC*]]List=parseJSONString(result);
            }
            else
            {
            }

         }
         catch (Exception g)
         {
            g.printStackTrace();
         }
      }
      catch (Exception h)
      {

      }

      return [[*viewNameLC*]]List;
   }

   private ArrayList<[[*viewNameUC*]]DTO> parseJSONString(String result)
   {
      ArrayList<[[*viewNameUC*]]DTO> [[*viewNameLC*]]List=new ArrayList<[[*viewNameUC*]]DTO>();

      JSONArray ja=null;

      try
      {
         ja=new JSONArray(result);
      }
      catch (JSONException e)
      {
         e.printStackTrace();
      }

      for (int i=0; i < ja.length(); i++)
      {

         JSONObject oneObject=null;

         try
         {
            oneObject=ja.getJSONObject(i);
         }
         catch (JSONException e)
         {
            e.printStackTrace();
         }

         // Pulls items from the array.
         try
         {
[[*jsonFetchForAppWS*]]

            [[*viewNameUC*]]DTO [[*viewNameLC*]]=new [[*viewNameUC*]]DTO();
            
            
[[*jsonSettersforAppWS*]]

            
            [[*viewNameLC*]]List.add([[*viewNameLC*]]);

         }
         catch (JSONException e)
         {
            e.printStackTrace();
         }

      }

      return [[*viewNameLC*]]List;

   }

   private static String convertInputStreamToString(InputStream inputStream) throws IOException
   {
      BufferedReader bufferedReader=new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));

      int c;
      StringBuilder response=new StringBuilder();

      while ((c=bufferedReader.read()) != -1)
      {
         response.append((char) c);
      }
      String result=response.toString();
      inputStream.close();

      return result;

   }

}
