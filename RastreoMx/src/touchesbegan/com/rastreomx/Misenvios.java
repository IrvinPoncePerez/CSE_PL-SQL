package touchesbegan.com.rastreomx;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;

import touchesbegan.rastreomx.database.MySQLiteHelper;
import touchesbegan.rastreomx.database.Paquete;
import android.app.ActionBar;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

public class Misenvios extends Activity implements OnItemClickListener {

	ListView listView;
	List<List_paquete> rowItems;

	TextView tv;
	Paquete p;
	List<Paquete> values;
	String estado;
	String[] values1;
	MySQLiteHelper MDB;
	String url1, url2;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_misenvios);

		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		tv = (TextView) findViewById(R.id.textView1);
		values = new ArrayList<Paquete>();
		listView = (ListView) findViewById(R.id.listViewCompra);
		ActionBar bar = getActionBar();
		bar.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#F05157")));

		MDB = new MySQLiteHelper(getApplicationContext());
		MDB.verTodos();
		if (MDB.verTodos().isEmpty()) {
			tv.setText("Tu lista de envíos está vacía");
		}

		values = (ArrayList<Paquete>) MDB.verTodos();
		/*
		 * final ArrayAdapter<Paquete> adapter = new ArrayAdapter<Paquete>(this,
		 * android.R.layout.simple_list_item_1, values); Log.v("ADAPTER",
		 * adapter.isEmpty() + ""); lista.setAdapter(adapter);
		 */

		ArrayList<String> lista2 = new ArrayList<String>();
		ArrayList<String> paqueterias = new ArrayList<String>();
		Integer[] images = { R.drawable.ups, R.drawable.fedex,
				R.drawable.correosdemexico, R.drawable.estafeta,
				R.drawable.paquete_express, R.drawable.tresguerras,
				R.drawable.redpack, R.drawable.envia,
				R.drawable.flechaamarilla, R.drawable.dhl, R.drawable.castores,
				R.drawable.odmexpress, R.drawable.aeromexico, R.drawable.paquer };

		HashMap<String, String> hm = new HashMap<String, String>();
		for (Paquete p : values) {
			hm.put(p.getClave(), p.getPaqueteria());
		}
		rowItems = new ArrayList<List_paquete>();
		Iterator it = hm.entrySet().iterator();

		while (it.hasNext()) {
			Map.Entry e = (Map.Entry) it.next();
			Log.v("Hashmap", "key= " + e.getKey() + " value= " + e.getValue());
			String x = (String) e.getValue();
			if (x.contains("UPS")) {
				List_paquete lp = new List_paquete(R.drawable.ups,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("Fedex")) {
				List_paquete lp = new List_paquete(R.drawable.fedex,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("Correos")) {
				List_paquete lp = new List_paquete(R.drawable.correosdemexico,
						(String) e.getKey());
				rowItems.add(lp);
			}
			/*if (x.contains("DHL")) {
				List_paquete lp = new List_paquete(R.drawable.correosdemexico,
						(String) e.getKey());
				rowItems.add(lp);
			}*/
			if (x.contains("Estafeta")) {
				List_paquete lp = new List_paquete(R.drawable.estafeta,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("Paquete")) {
				List_paquete lp = new List_paquete(R.drawable.paquete_express,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("Tres")) {
				List_paquete lp = new List_paquete(R.drawable.tresguerras,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("Red")) {
				List_paquete lp = new List_paquete(R.drawable.redpack,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("Envia")) {
				List_paquete lp = new List_paquete(R.drawable.envia,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("Flecha")) {
				List_paquete lp = new List_paquete(R.drawable.flechaamarilla,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("DHL")) {
				List_paquete lp = new List_paquete(R.drawable.dhl,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("Castores")) {
				List_paquete lp = new List_paquete(R.drawable.castores,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("ODM")) {
				List_paquete lp = new List_paquete(R.drawable.odmexpress,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("Aero")) {
				List_paquete lp = new List_paquete(R.drawable.aeromexico,
						(String) e.getKey());
				rowItems.add(lp);
			}
			if (x.contains("Paquer")) {
				List_paquete lp = new List_paquete(R.drawable.paquer,
						(String) e.getKey());
				rowItems.add(lp);
			}
		}
		CustomBaseAdapter adapter = new CustomBaseAdapter(this, rowItems);
		listView.setAdapter(adapter);
		listView.setOnItemClickListener(this);
		
	}

	public void Volver(View v) {
		Intent volver = new Intent(this, Misenvios.class);
		startActivity(volver);
	}

	public void seleccion(View v) {

		switch (v.getId()) {
		case R.id.Agregar:
			Intent agregar = new Intent(this, MainActivity.class);
			startActivity(agregar);
			break;

		case R.id.cotizar:
			Intent cotizar = new Intent(this, Cotizar.class);
			startActivity(cotizar);
			break;

		case R.id.ajustes:
			Intent ajustes = new Intent(this, Ajustes.class);
			startActivity(ajustes);
			break;

		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.misenvios, menu);
		return true;
	}

	/**
	 * Clase que sirve para buscar paquete en UPS
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultUps extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion, recibio;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en UPS");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				Document document2 = Jsoup.connect(url2).get();
				Elements table = document
						.select("div[class=secLvl gradient gradientGroup7 module3] fieldset div[class=secBody] table[class=dataTable] tr");
				Elements table2 = document2
						.select("div[class=appBody clearfix] dl");
				tabla = "<html><head><style>table, th, td {border: 1px solid black;}</style></head><body><table><tbody>"
						+ table.toString()
						+ "</tbody></table></hr>"
						+ table2
						+ "</body></html>";
				Log.v("Tabla2", table2.toString());
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}
	}

	/**
	 * Clase que sirve para buscar paquete en Fedex
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultFedex extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion, recibio;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en Fedex");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				Elements table = document
						.select("table[id= track-info-progress]");
				Elements table2 = document
						.select("table[id=track-info-summary] tbody tr");
				tabla = "<html><head><style>table, th, td {border: 1px solid black;}</style></head><body>"
						+ table.toString()
						+ "</br>"
						+ table2.get(5).toString()
						+ "</br>"
						+ table2.get(6).toString()
						+ "</br>"
						+ table2.get(7).toString()
						+ "</br>"
						+ table2.get(8).toString()
						+ "</br>"
						+ table2.get(9).toString()
						+ "</br>"
						+ table2.get(10).toString()
						+ "</br>"
						+ table2.get(11).toString() + "</body></html>";
				Log.v("Tabla2", tabla);
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}

	}

	/**
	 * Clase que sirve para buscar paquete en Fedex
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultFlechaAmarilla extends
			AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion, recibio;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en Flecha Amarilla");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {
			try {
				Document document = Jsoup.connect(url1).get();
				Elements table = document.select("table[id= tblGuia]");
				// Elements table2 =
				// document.select("table[id=track-info-summary] tbody tr");
				tabla = "<html><head><style>table{width:100%;}table, th, td {border: 1px solid black;}</style></head><body>"
						+ table.toString() + "</body></html>";
				Log.v("Tabla2", tabla);
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}

	}

	private class SearchResultCorreos extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion, recibio;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en Correos de México");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {
			try {
				Document document = Jsoup.connect(url1).get();
				Elements table = document.select("tr[class=result]");
				// Elements table2 =
				// document.select("table[id=track-info-summary] tbody tr");
				tabla = "<html><head><style>table{width:100%;}table, th, td {border: 1px solid black;}</style></head><body>"
						+ "<table><tbody><tr>"
						+ table.toString()
						+ "</tr></table></tbody>" + "</body></html>";
				Log.v("Tabla2", tabla);
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}

	}
	private class SearchResultPaquer extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion, recibio;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en Paquer");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {
			try {
				Document document = Jsoup.connect(url1).get();
				Elements table = document.select("div[class=span9 contenido] table");
				
				// Elements table2 =
				// document.select("table[id=track-info-summary] tbody tr");
				tabla = "<html><head><style>.span9 contenido{width:100%;}</style></head><body>"
						+ table.get(1).toString()
						+"</body></html>";
				//Log.v("Tabla2", table.toString());
			}catch(SocketTimeoutException se){
				se.printStackTrace();
				Handler handler =  new Handler(getApplicationContext().getMainLooper());
			    handler.post( new Runnable(){
			        public void run(){
			            Toast.makeText(getApplicationContext(), "Algo salió mal, intenta de nuevo",Toast.LENGTH_LONG).show(); 
			        }
			    });
			}
			catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}

	}

	/**
	 * Clase que sirve para buscar paquete en ODM
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultODM extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion, recibio;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en ODM");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {
			try {
				Document document = Jsoup.connect(url1).get();
				Elements table = document.select("div[id=resultados_rastreo]");
				// Elements table2 =
				// document.select("table[id=track-info-summary] tbody tr");
				Log.v("asd", table.toString());
				tabla = "<html><head><style>table{width:100%;}table, th, td {border: 1px solid black;}</style></head><body>"
						+ table.toString() + "</body></html>";
				Log.v("Tabla2", tabla);
			} catch (SocketTimeoutException se) {
				this.cancel(isFinishing());
			} catch (IOException e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}

	}

	/**
	 * Clase que sirve para buscar paquete en RedPack
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultRedPack extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion, recibio;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en RedPack");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {
			try {
				Document document = Jsoup.connect(url1).get();
				Elements table = document
						.select("table[class=tabla-detalle-guia-rastreos]");
				// Elements table2 =
				// document.select("table[id=track-info-summary] tbody tr");
				tabla = "<html><head><style>table, th, td {border: 1px solid black;}</style></head><body>"
						+ table.toString() + "</body></html>";
				Log.v("Tabla2", tabla);
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}

	}

	/**
	 * Clase que sirve para buscar paquete en RedPack
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultPaqueteExpress extends
			AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion, recibio;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en PaqueteExpress");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {
			try {
				Document document = Jsoup.connect(url1).get();
				Elements table = document
						.select("table[class=tabla__padding-everywhere tabla__zebra]");
				tabla = "<html><head><style>table{width:100%;}table, th, td {border: 1px solid black;}</style></head><body>"
						+ table.toString() + "</body></html>";
				Log.v("Tabla2", tabla);
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}

	}

	private class SearchResultCastores extends AsyncTask<Void, Void, String> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion, recibio;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en Castores");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected String doInBackground(Void... arg0) {
			try {
				Document document = Jsoup.connect(url1).get();
				Elements table = document.select("table");
				tabla = "<html><head><style>table{width:100%;}</style></head><body>"
						+ table.get(0).toString() + "</body></html>";
				Log.v("Tabla2", tabla);
			}catch(SocketTimeoutException se){
				return "fail";
			}
			catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(String result) {
			if(result.equalsIgnoreCase("fail")){
				Toast.makeText(getApplicationContext(), "Error de conexión, por favor intenta de nuevo más tarde", Toast.LENGTH_LONG).show();
			}
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}

	}

	/**
	 * Clase que sirve para buscar paquetes en Estafeta
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultEstafeta extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en Estafeta");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {

				JSONObject json = readJsonFromUrl(url1);
				ArrayList<String> x = new ArrayList<String>();
				JSONArray result = json.getJSONArray("movimientos");
				for (int i = 0; i < result.length(); i++) {
					// Log.v("JSON","id= "+result.getJSONObject(i).getString("id")+" pos= "+i);
					// Log.v("JSON","fecha= "+result.getJSONObject(i).getString("fecha")+" pos= "+i);
					// Log.v("JSON","descripcion= "+result.getJSONObject(i).getString("descripcion")+" pos= "+i);
					String html = "<tr>" + "<td>"
							+ result.getJSONObject(i).getString("fecha")
							+ "</td><td>"
							+ result.getJSONObject(i).getString("descripcion")
							+ "</td></tr>";
					Log.v("HTml", "html= " + html);
					x.add(html);
				}
				String res = "";
				for (String t : x) {
					res = res + t;
				}
				tabla = "<html><head><style>table{width:100%;} table, tr, td {border: 1px solid black;}</style></head><body><table><thead><tr>"
						+ "<th>Fecha</th><th>descripcion</th></tr></thead><tbody>"
						+ res + "<tbody><table></body></html>";

			} catch (Exception e) {

				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}

		
		
		private String readAll(Reader rd) throws IOException {
			StringBuilder sb = new StringBuilder();
			int cp;
			while ((cp = rd.read()) != -1) {
				sb.append((char) cp);
			}
			return sb.toString();
		}

		private JSONObject readJsonFromUrl(String url) throws IOException,
				JSONException {
			InputStream is = new URL(url).openStream();
			try {
				BufferedReader rd = new BufferedReader(new InputStreamReader(
						is, Charset.forName("UTF-8")));
				String jsonText = readAll(rd);
				JSONObject json = new JSONObject(jsonText);
				return json;
			} finally {
				is.close();
			}
		}

	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		// TODO Auto-generated method stub
		Log.v("ITEM", rowItems.get(position).getImageId() + "");
		if (rowItems.get(position).getImageId() == R.drawable.ups) {
			String numGuia = rowItems.get(position).getClave();
			String url = "http://wwwapps.ups.com/ietracking/tracking.cgi?loc=es_es&tracknum=";
			url1 = url + numGuia;
			url2 = "http://wwwapps.ups.com/WebTracking/processPOD?Requester=&tracknum="
					+ numGuia + "&refNumbers=&loc=en_US";
			Log.v("Link", url1);
			new SearchResultUps().execute();
		}
		if (rowItems.get(position).getImageId() == R.drawable.estafeta) {
			String numGuia = rowItems.get(position).getClave();
			String url = "http://clients.touchesbegan.com/estafetaFinal/estafeta-api/index.php/estafeta/rastreo?numero=";
			url1 = url + numGuia;
			Log.v("Link", url1);
			new SearchResultEstafeta().execute();
		}
		if (rowItems.get(position).getImageId() == R.drawable.correosdemexico) {
			
			String numGuia = rowItems.get(position).getClave();
			String url = "http://www.trackitonline.ru/?tn=";
			url1 = url + numGuia;
			Log.v("Link", url1);
			new SearchResultCorreos().execute();
		}
		if (rowItems.get(position).getImageId() == R.drawable.fedex) {
			String numGuia = rowItems.get(position).getClave();
			String url = "https://www.packagetrackr.com/track/fedex/";
			url1 = url + numGuia;
			Log.v("Link", url1);
			new SearchResultFedex().execute();
		}
		if (rowItems.get(position).getImageId() == R.drawable.flechaamarilla) {
			
			String numGuia = rowItems.get(position).getClave();
			String url = "http://srvwebgfa.cloudapp.net/gfa/pymfa/Rastreoenvio/tabid/488/C/P/NUM/"
					+ numGuia + "/Default.aspx";
			url1 = url;
			Log.v("Link", url1);
			new SearchResultFlechaAmarilla().execute();
		}
		if (rowItems.get(position).getImageId() == R.drawable.odmexpress) {
		
			String numGuia = rowItems.get(position).getClave();
			String url = "http://odmexpress.com.mx/rastreo-2/?rastreo_fall=";
			url1 = url + numGuia;
			Log.v("Link", url1);
			new SearchResultODM().execute();
		}
		if (rowItems.get(position).getImageId() == R.drawable.redpack) {
			
			String numGuia = rowItems.get(position).getClave();
			String url = "http://www.redpack.com.mx/RpkWeb/RastreoEnvios?guias=";
			url1 = url + numGuia;
			Log.v("Link", url1);
			new SearchResultRedPack().execute();
		}
		if (rowItems.get(position).getImageId() == R.drawable.paquete_express) {
			String numGuia = rowItems.get(position).getClave();
			String url = "http://www.paquetexpress.com.mx/rastreofiafenew.jsp?guia=";
			url1 = url + numGuia;
			Log.v("Link", url1);
			new SearchResultPaqueteExpress().execute();
		}
		if (rowItems.get(position).getImageId() == R.drawable.castores) {
			String numGuia = rowItems.get(position).getClave();
			String url = "http://tomcat1.castores.com.mx/CyberFacturacion/app/static/estatus_talon?talon=";
			url1 = url + numGuia;
			Log.v("Link", url1);
			new SearchResultCastores().execute();
		}
		if (rowItems.get(position).getImageId() == R.drawable.paquer) {
			String numGuia = rowItems.get(position).getClave();
			String url = "http://touchesbegan.com/devadmin/handler.php?c=7&sn=";
			String x []=numGuia.split(" "); 
			Log.v("Link",x[0]);
			url1 = url + x[0];
			Log.v("Link", url1);
			new SearchResultPaquer().execute();
		}
		
		if (rowItems.get(position).getImageId() == R.drawable.dhl) {
			String numGuia = rowItems.get(position).getClave();
			String url = "https://track.aftership.com/dhl/";
			url1 = url + numGuia+"/";
			Log.v("Link", url1);
			new SearchResultDHL().execute();
		}

	}
	private class SearchResultDHL extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion, recibio;
		String tabla;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Misenvios.this);
			mProgressDialog.setTitle("Búsqueda en DHL");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {
			try {
				Document document = Jsoup.connect(url1).get();
				Elements table = document.select("div[class=timeline-container]");
				// Elements table2 =
				// document.select("table[id=track-info-summary] tbody tr");
				tabla = "<html><head><style>.timeline-container{width:100%;}</style><meta charset ="+"UTF-8"+"></head><body>"
						+ table.toString()
						+"</body></html>";
				Log.i("Tabla2", tabla);
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Misenvios.this, InfoDetail.class);
			i.putExtra("html", tabla);
			startActivity(i);
		}

	}

}
