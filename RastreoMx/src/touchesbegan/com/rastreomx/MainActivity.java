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

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;

import touchesbegan.com.rastreomx.R.drawable;
import android.app.ActionBar;
import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;

public class MainActivity extends Activity {
	EditText ingresaClave;
	// BOTONES
	Button ups, dhl, fedex, estafeta, paqueteExpress, redPack, envia,
			tresGuerras, flechaAmarilla, correosDeMexico, otra, odm, castores,
			aeromexico, paquer;

	// DATA
	String dataDhl, dataUps, dataFedex, dataEstafeta, dataPaqueteExpress,
			dataTresGuerras, dataRedPack, dataEnvia, dataFlechaAmarilla,
			dataCorreosDeMexico, dataODM, dataCastores, dataPaquer;// Falta
																	// correos

	String paquete;
	String sn;
	Intent info;
	int currier;
	String currier2;
	ArrayList<String> resultado;
	private String url;
	private String url1;
	private String url2;
	String data;
	String id;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		resultado = new ArrayList<String>();
		ActionBar bar = getActionBar();
		bar.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#F05157")));
		bar.setLogo(R.drawable.rastreomxicono);
		ingresaClave = (EditText) findViewById(R.id.clave);

		// INICIACION BOTONES

		dhl = (Button) findViewById(R.id.button3);
		ups = (Button) findViewById(R.id.odmWeb);
		fedex = (Button) findViewById(R.id.fAmarilla);
		correosDeMexico = (Button) findViewById(R.id.button6);
		estafeta = (Button) findViewById(R.id.button7);
		paqueteExpress = (Button) findViewById(R.id.button8);
		redPack = (Button) findViewById(R.id.button10);
		envia = (Button) findViewById(R.id.button11);
		tresGuerras = (Button) findViewById(R.id.button13);
		flechaAmarilla = (Button) findViewById(R.id.button17);
		odm = (Button) findViewById(R.id.buttonODM);
		castores = (Button) findViewById(R.id.castores);
		aeromexico = (Button) findViewById(R.id.aeromexico);
		paquer = (Button) findViewById(R.id.paquer);
		/*
		 * otra = (Button) findViewById(R.id.otra);
		 * otra.setBackgroundColor(Color.argb(127, 255, 0, 0));
		 * otra.setText("Otra"); otra.setTextColor(Color.WHITE);
		 */
		// CLAVES DE PAQUETERIAS

		dataDhl = "1550528733";
		dataUps = "1ZR7V9390367833646";
		dataFedex = "591866014456";
		dataEstafeta = "1313345710";
		dataPaqueteExpress = "966129236007";
		dataRedPack = "403420898";
		dataEnvia = "0080035623";
		dataTresGuerras = "12127423";
		dataFlechaAmarilla = "6787628";
		dataCorreosDeMexico = "MN401089725MX";
		dataODM = "R7919762";
		dataCastores = "09010273094";

		// PARTE DE ADS

		AdView adView = (AdView) this.findViewById(R.id.adView);
		AdRequest adRequest = new AdRequest.Builder().build();
		adView.loadAd(adRequest);

		// PONER CLAVE EN EL CAMPO DE TEXTO
		//ingresaClave.setText(dataDhl);

		// AGREGAR ACCIONES A BOTONES

		paquer.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				paquer.setBackgroundResource(R.drawable.paquer);
				data = ingresaClave.getText().toString();
				url1 = "http://touchesbegan.com/devadmin/handler.php?c=7&sn="
						+ data;
				if (verifica(data)) {
					id = "8";
					new SearchResultPaquer().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					castores.setBackgroundResource(R.drawable.castores_black);
				}

			}
		});

		ups.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				ups.setBackgroundResource(R.drawable.ups);
				data = ingresaClave.getText().toString();
				url = "http://touchesbegan.com/devadmin/handler.php?c=2&sn=";
				url1 = url + data;
				if (verifica(data)) {
					id = "2";
					new SearchResultUps().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					ups.setBackgroundResource(R.drawable.ups_gray);
				}

			}
		});
		dhl.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				dhl.setBackgroundResource(R.drawable.dhl);
				data = ingresaClave.getText().toString();
				// url1 =
				// "http://www.dhl.com.mx/content/mx/es/express/rastreo.shtml?AWB="+data+"&brand=DHL";
				url1 = "http://www.trackitonline.ru/?tn=" + data;

				if (verifica(data)) {
					id = "3";
					new SearchResultDHL().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					dhl.setBackgroundResource(R.drawable.dhl_gray);
				}
			}

		});
		fedex.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				fedex.setBackgroundResource(R.drawable.fedex);
				data = ingresaClave.getText().toString();
				url1 = "http://www.packagetrackr.com/track/fedex/" + data;
				if (verifica(data)) {
					id = "4";
					new SearchResultFedex().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					fedex.setBackgroundResource(R.drawable.fedex_black);
				}

			}

		});

		correosDeMexico.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				correosDeMexico
						.setBackgroundResource(R.drawable.correosdemexico);
				data = ingresaClave.getText().toString();
				// url1 =
				// "http://www.17track.net/en/result/post-details.shtml?nums="
				// + data;

				url1 = "http://www.trackitonline.ru/?tn=" + data;
				if (verifica(data)) {
					id = "5";
					new SearchResultCorreosDeMexico().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					correosDeMexico
							.setBackgroundResource(R.drawable.correosdemexico_black);
				}

			}

		});

		estafeta.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				estafeta.setBackgroundResource(R.drawable.estafeta);
				data = ingresaClave.getText().toString();
				url1 = "http://www.braindepot.com.mx/estafeta-api/api/?numero="
						+ data;
				if (verifica(data)) {
					id = "6";
					new SearchResultEstafeta().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					estafeta.setBackgroundResource(R.drawable.estafeta_black);
				}

			}
		});

		paqueteExpress.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				paqueteExpress
						.setBackgroundResource(R.drawable.paquete_express);
				data = ingresaClave.getText().toString();
				url1 = "http://www.paquetexpress.com.mx/verfirma.jsp?RASTREO="
						+ data;
				if (verifica(data)) {
					id = "7";
					new SearchResultPaqueteExpress().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					paqueteExpress
							.setBackgroundResource(R.drawable.paquete_express_black);
				}

			}

		});
		/**
		 * AQUI VA PAQUER
		 * 
		 */
		redPack.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				redPack.setBackgroundResource(R.drawable.redpack);
				data = ingresaClave.getText().toString();
				url1 = "http://touchesbegan.com/devadmin/handler.php?c=8&sn="
						+ data;
				if (verifica(data)) {
					id = "9";
					new SearchResultRedPack().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					redPack.setBackgroundResource(R.drawable.redpack);
				}
			}

		});
		envia.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				envia.setBackgroundResource(R.drawable.envia);

				data = ingresaClave.getText().toString();
				url1 = "http://touchesbegan.com/devadmin/handler.php?c=10&sn="
						+ data;
				if (verifica(data)) {
					id = "10";
					new SearchResultEnvia().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					envia.setBackgroundResource(R.drawable.envia_black);
				}
			}
		});

		/**
		 * AQUI VA AEROMEXICO CARGO
		 */
		aeromexico.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				aeromexico.setBackgroundResource(R.drawable.aeromexico);
				final Dialog dialog = new Dialog(MainActivity.this);
				dialog.setContentView(R.layout.custom_dialog);
				dialog.setTitle("¡Ayúdanos a mejorar!");
				Button cancel = (Button) dialog.findViewById(R.id.cancelar);
				// if button is clicked, close the custom dialog
				cancel.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View v) {
						dialog.dismiss();
						aeromexico
								.setBackgroundResource(R.drawable.aeromexico_black);
					}
				});
				Button enviar = (Button) dialog.findViewById(R.id.enviar);
				// if button is clicked, close the custom dialog
				enviar.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View v) {
						EditText edita = (EditText) dialog
								.findViewById(R.id.editText1);
						if (edita.length() == 0) {
							Toast.makeText(getApplicationContext(),
									"llena el campo de la guia",
									Toast.LENGTH_LONG).show();
						} else {
							aeromexico
									.setBackgroundResource(R.drawable.aeromexico_black);
							sendFeedback(edita.getText().toString());
						}
					}
				});
				dialog.show();
			}

		});

		tresGuerras.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				tresGuerras.setBackgroundResource(R.drawable.tresguerras);
				data = ingresaClave.getText().toString();
				url1 = "http://www.tresguerras.com.mx:8080/web/tresguerras/track?p_p_id=rastreo_WAR_track2ES&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-2&p_p_col_pos=3&p_p_col_count=5&_rastreo_WAR_track2ES_accion=DetalleTraking&talon="
						+ data;
				if (verifica(data)) {
					id = "12";
					new SearchResultTresGuerras().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					tresGuerras
							.setBackgroundResource(R.drawable.tresguerras_black);
				}

			}
		});
		flechaAmarilla.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				flechaAmarilla.setBackgroundResource(R.drawable.flechaamarilla);
				data = ingresaClave.getText().toString();
				url1 = "http://srvwebgfa.cloudapp.net/gfa/pymfa/Rastreoenvio/tabid/488/C/P/NUM/"
						+ data + "/Default.aspx";
				if (verifica(data)) {
					id = "15";
					new SearchResultFlechaAmarilla().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					flechaAmarilla
							.setBackgroundResource(R.drawable.flechaamarillablack);
				}

			}

		});
		odm.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				odm.setBackgroundResource(R.drawable.odmexpress);
				data = ingresaClave.getText().toString();
				url1 = "http://odmexpress.com.mx/rastreo-2/?rastreo_fall="
						+ data;
				if (verifica(data)) {
					id = "14";
					new SearchResultOdmExpress().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					odm.setBackgroundResource(R.drawable.odmexprress_black);
				}

			}

		});

		castores.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				castores.setBackgroundResource(R.drawable.castores);
				data = ingresaClave.getText().toString();
				url1 = "http://tomcat1.castores.com.mx/CyberFacturacion/app/static/estatus_talon?talon="
						+ data;
				if (verifica(data)) {
					id = "13";
					new SearchResultCastores().execute();
				} else {
					Toast.makeText(getApplicationContext(), "Clave no valida",
							Toast.LENGTH_SHORT).show();
					castores.setBackgroundResource(R.drawable.castores_black);
				}

			}
		});

		/*
		 * otra.setOnClickListener(new OnClickListener() {
		 * 
		 * @Override public void onClick(View arg0) { Intent i = new
		 * Intent(MainActivity.this, EnviaGuiaActivity.class); startActivity(i);
		 * }
		 * 
		 * });
		 */
	}

	public void Volver(View v) {
		Intent volver = new Intent(this, Misenvios.class);
		startActivity(volver);
	}

	/**
	 * 
	 * @param x
	 *            Cadena, clave a buscar
	 * @return true si el campo de texto está vacío, false si no
	 */
	public boolean verifica(String x) {
		if (x.equals("")) {
			return false;
		} else {
			return true;
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);

		return true;
	}

	public String getServerDataGET(String targetURL)

	throws ClientProtocolException, IOException {
		try {
			HttpClient client = new DefaultHttpClient();
			HttpUriRequest request = new HttpGet(targetURL);
			HttpResponse response = client.execute(request);
			String responseBody = "";
			HttpEntity entity = response.getEntity();

			if (entity != null) {
				responseBody = EntityUtils.toString(entity);
			}
			return responseBody;

		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	/**
	 * Clase que sirve para buscar paquete en DHL
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultDHL extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, fecha, situacion,result;
		String key;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en DHL");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {
			try {
				Document document = Jsoup.connect(url1).get();
				/*
				 * Elements documento = document
				 * .select("section ul[class=guild-title] li span[data-role=number]"
				 * ); for (int i = 0; i < documento.size(); i++) {
				 * Log.v("documento", documento.get(i).text() + ""); }
				 */
				result = document.select("tr[class=result] td");
				for (int i = 0; i < result.size(); i++) {
					Log.i("Result", result.get(i).text() + " Posicion: " + i);
				}

				clave = document.select("center h2");
				fecha = document.select("div nobr");
				situacion = document
						.select("td strong span[title=Entregado] u");

				resultado.add(clave.text());

				
				String []origen = result.get(2).text().split("envío");
				resultado.add(origen[1]);// Origen
			    
				
				
				String destino[] = result.get(result.size()-3).text().split("\\]");
				resultado.add(destino[1]);//result.get(result.size() - 3).text());// Destino
				resultado.add(document.select("tr[class=result] td div nobr")
						.get(0).text());
				// resultado.add(situacion.text());

			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			if (clave.size()==0) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				mProgressDialog.dismiss();
				dhl.setBackgroundResource(R.drawable.dhl_gray);
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				dhl.setBackgroundResource(R.drawable.dhl_gray);
				mProgressDialog.dismiss();
			}
		}

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

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en UPS");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				clave = document.select("h3[id=trkNum]");
				origen = document.select("td[class=nowrap]");
				destino = document.select("Strong");
				fecha = document.select("dd");
				situacion = document.select("a[id=tt_spStatus]");
				recibio = document.select("dt");

				Log.v("elementos: ", clave.text() + " " + origen.text() + " ");

				resultado.add(clave.text());
				resultado.add("no se tiene información");
				resultado.add(destino.text().toLowerCase());
				resultado.add(fecha.get(0).text());
				resultado.add(situacion.text());
				resultado.add(recibio.get(3).text());

			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			if (clave.size() == 0) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				ups.setBackgroundResource(R.drawable.ups_gray);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();

				ups.setBackgroundResource(drawable.ups_gray);
				mProgressDialog.dismiss();
			}
		}

	}

	/**
	 * Clase que sirve para buscar paquetes en Fedex
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultFedex extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, situacion;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en Fedex");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				clave = document
						.select("td[class=track-info-summary-value entry-title]");
				origen = document.select("td[class=track-info-summary-value]");
				situacion = document.select("div[id=track-info-status]");
				String situacionN[] = situacion.text().split(" ");

				resultado.add(clave.get(1).text());
				resultado.add(origen.get(2).text());// origen
				resultado.add(origen.get(4).text());// destino
				resultado.add(origen.get(5).text());// fecha
				resultado.add(situacionN[0]);// situacion
				resultado.add(origen.get(7).text());// quien
				imprime(situacion);

			} catch (Exception e) {

				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			if (resultado.size() == 0) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				fedex.setBackgroundResource(R.drawable.fedex_black);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				fedex.setBackgroundResource(R.drawable.fedex_black);
				mProgressDialog.dismiss();
			}
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

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en Estafeta");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {

				JSONObject json = readJsonFromUrl(url1);

				resultado.add(json.getString("codigo_rastreo"));
				resultado.add(json.getJSONObject("origen").getString("nombre"));
				resultado
						.add(json.getJSONObject("destino").getString("nombre"));
				resultado.add(json.getString("fecha_entrega"));
				resultado.add(json.getString("estatus_envio"));

			} catch (Exception e) {

				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			if (resultado.size() == 0) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				estafeta.setBackgroundResource(R.drawable.estafeta_black);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				estafeta.setBackgroundResource(R.drawable.estafeta_black);
				mProgressDialog.dismiss();
			}
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

	/**
	 * Clase que sirve para buscar paquetes en Paquete express
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultPaqueteExpress extends
			AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, result;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en Paquete Express");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				clave = document
						.select("table tbody tr td div[class=txt__large]");
				result = document.select("table tbody tr td span");
				Log.v("clave", clave.get(0).text());
				if (result.isEmpty()) {
					Log.i("EST�? VAC�?O", "EST�? VAC�?O");
				}
				for (int i = 0; i < result.size(); i++) {
					Log.v("resultado en tabla", result.get(i).text()
							+ " posicion: " + i);
				}
				resultado.add(clave.text());
				if (!clave.text().contains("JRun Servlet Error")) {

					resultado.add(result.get(16).text());
					resultado.add(result.get(18).text());// destino
					resultado.add(result.get(22).text());// fecha
					resultado.add(result.get(26).text());// situacion
					resultado.add(result.get(20).text());// quien lo
				}

			} catch (SocketTimeoutException se) {
				Log.v("SOCKET TIME OUT", "HUBO UN SOCKETTIMEOUT EXCEPTION");
			} catch (IOException e) {
				e.printStackTrace();
			}

			return null;
		}

		protected void onPostExecute(Void result) {

			if (clave == null
					|| clave.toString().contains("JRun Servlet Error")) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				paqueteExpress
						.setBackgroundResource(R.drawable.paquete_express_black);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				paqueteExpress
						.setBackgroundResource(R.drawable.paquete_express_black);
				mProgressDialog.dismiss();
			}
		}

	}

	/**
	 * Clase para buscar paquetes en RedPack
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultRedPack extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements result, clave;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en RedPack");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				clave = document.select("td[class=nombre_guia_rastreo]");
				imprime(clave);
				result = document.select("table tbody tr td span");
				imprime(result);

				String claveN[] = clave.text().split(" ");
				String claveX[] = claveN[1].split("#");
				resultado.add(claveX[1]);

				String origenN[] = result.get(1).text().split(": ");
				resultado.add(origenN[1]);

				String destinoN[] = result.get(2).text().split(": ");
				resultado.add(destinoN[1]);

				String fechaN[] = result.get(4).text().split(": ");
				resultado.add(fechaN[1]);

				String situacionN[] = result.get(3).text().split(": ");
				resultado.add(situacionN[1]);

				String recibioN[] = result.get(5).text().split(": ");
				resultado.add(recibioN[1]);
				/*
				 * result = document.select("table tbody tr td span");
				 * imprime(result);
				 */

			} catch (Exception e) {

				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			if (resultado.size() == 0) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				redPack.setBackgroundResource(R.drawable.redpack_black);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				redPack.setBackgroundResource(R.drawable.redpack_black);
				mProgressDialog.dismiss();
			}
		}

	}

	/**
	 * Clase que sirve para buscar paquetes en Envia
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultEnvia extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements result;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en Envía");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();

				result = document.select("body");
				String r = result.text();
				String m[] = r.split("\\|");
				imprimeArreglo(m);
				resultado.add(m[2]);
				resultado.add(m[4]);
				resultado.add(m[5]);
				resultado.add(m[15]);
				resultado.add(m[1]);
				String quien[] = m[16].split("ENTREGADO A: ");
				resultado.add(quien[1]);

			} catch (Exception e) {

				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			if (resultado.size() == 0) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				envia.setBackgroundResource(R.drawable.envia_black);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				envia.setBackgroundResource(R.drawable.envia_black);
				mProgressDialog.dismiss();
			}
		}

	}

	/**
	 * Clase que sirve para buscar paquetes en TresGuerras
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultTresGuerras extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements result, clave;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en Tres Guerras");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				clave = document.select("span[class=style1]");
				imprime(clave);
				String claveN[] = clave.get(0).text().split(": ");
				result = document.select("table[width=100%] tbody tr td");
				imprime(result);
				resultado.add(claveN[1]);
				resultado.add(result.get(6).text());
				resultado.add(result.get(1).text());
				resultado.add(result.get(2).text());
				resultado.add(result.get(0).text());
				resultado.add(result.get(4).text());
			} catch (Exception e) {

				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			if (clave.size() == 0) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				tresGuerras.setBackgroundResource(R.drawable.tresguerras_black);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				tresGuerras.setBackgroundResource(R.drawable.tresguerras_black);
				mProgressDialog.dismiss();
			}
		}

	}

	/**
	 * Clase que sirve para buscar paquetes en Flecha amarilla
	 * 
	 * @author MiguelAngel
	 * 
	 */

	private class SearchResultFlechaAmarilla extends
			AsyncTask<Void, Void, String> {
		ProgressDialog mProgressDialog;
		Elements clave, origen, destino, situacion;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en Flecha amarilla");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected String doInBackground(Void... arg0) {

			try {

				Document document = Jsoup.connect(url1).get();

				clave = document
						.select("span[id=dnn_ctr1013_ConsultaGuiaView_lblRNoGuia]");
				imprime(clave);
				origen = document
						.select("span[id=dnn_ctr1013_ConsultaGuiaView_lblROrigen]");
				destino = document
						.select("span[id=dnn_ctr1013_ConsultaGuiaView_lblRDestino]");
				situacion = document
						.select("span[id=dnn_ctr1013_ConsultaGuiaView_lblREstatus]");
				Elements result = document
						.select("table[class=rgMasterTable] tbody tr td");
				imprime(result);
				// String fec = result.get(result.size() - 4).text();
				resultado.add(clave.text());
				resultado.add(origen.text());
				resultado.add(destino.text());
				// resultado.add(fec);
				resultado.add(situacion.text());
				// String quien[] = result.last().text().split("Entregado a:");
				// resultado.add(quien[1]);

			}catch(SocketTimeoutException se){
				return "red";
			}
			catch (Exception e) {

				e.printStackTrace();
			}
			return "nice";
		}

		protected void onPostExecute(String result) {
			if(result.equalsIgnoreCase("red")){
				Toast.makeText(getApplicationContext(), "Error de conexión, intenta más tarde", Toast.LENGTH_LONG).show();
			}
			if (resultado.size() == 0) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				flechaAmarilla
						.setBackgroundResource(R.drawable.flechaamarillablack);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				flechaAmarilla
						.setBackgroundResource(R.drawable.flechaamarillablack);
				mProgressDialog.dismiss();
			}
		}

	}

	private class SearchResultCorreosDeMexico extends
			AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements result, clave, fecha, situacion;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en Correos de Mexico");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				/*
				 * Elements documento = document
				 * .select("section ul[class=guild-title] li span[data-role=number]"
				 * ); for (int i = 0; i < documento.size(); i++) {
				 * Log.v("documento", documento.get(i).text() + ""); }
				 */
				result = document.select("tr[class=result] td");
				
				for (int i = 0; i < result.size(); i++) {
					Log.i("Result", result.get(i).text() + " Posicion: " + i);
				}

				clave = document.select("center h2");
				fecha = document.select("div nobr");
				situacion = document
						.select("td strong span[title=Entregado] u");

				resultado.add(clave.text());

				resultado.add(result.get(2).text());// Origen
				// String destino[] =
				// result.get(result.size()-3).text().split(".");
				resultado.add(result.get(result.size() - 3).text());// Destino
				resultado.add(document.select("tr[class=result] td div nobr")
						.get(0).text());
				// resultado.add(situacion.text());

			} catch (Exception e) {

				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			if (resultado.size() == 0) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				correosDeMexico
						.setBackgroundResource(R.drawable.correosdemexico_black);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				correosDeMexico
						.setBackgroundResource(R.drawable.correosdemexico_black);
				mProgressDialog.dismiss();
			}
		}

	}

	/**
	 * Clase que sirve para buscar paquetes en Paquete express
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultOdmExpress extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, result;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en ODM Express");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				result = document
						.select("table tbody tr[class= rastreorow] td");

				if (result.isEmpty()) {
					Log.i("EST�? VAC�?O", "EST�? VAC�?O");
				}
				for (int i = 0; i < result.size(); i++) {
					Log.v("resultado en tabla", result.get(i).text()
							+ " posicion: " + i);
				}
				String status[] = result.get(result.size() - 1).text()
						.split(",");
				String quien[] = result.get(result.size() - 1).text()
						.split(":");
				String destino[] = result.get(result.size() - 5).text()
						.split("RECIBIDA EN : ");
				String dest[] = destino[1].split("\\[");
				String origen[] = result.get(result.size() - 5).text()
						.split("ORIGEN : ");

				resultado.add(result.get(0).text());// Clave
				resultado.add(origen[1]);// Origen
				// resultado.add(result.get(result.size()-13).text());//Origen
				resultado.add(dest[0]);
				// resultado.add(result.get(result.size()-5).text());// destino
				resultado.add(result.get(result.size() - 3).text());// fecha
				resultado.add(status[0]);// situacion
				resultado.add(quien[1]);// quien lo

			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void resultt) {
			if (!result.get(0).hasText()) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				odm.setBackgroundResource(R.drawable.odmexprress_black);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				odm.setBackgroundResource(R.drawable.odmexprress_black);
				mProgressDialog.dismiss();
			}
		}

	}

	/**
	 * Clase que sirve para buscar paquetes en Castores
	 * 
	 * @author MiguelAngel
	 * 
	 */
	private class SearchResultCastores extends AsyncTask<Void, Void, String> {
		ProgressDialog mProgressDialog;
		Elements clave, result;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en Castores");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected String doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				result = document.select("table tbody tr td");

				if (result.isEmpty()) {
					Log.i("EST�? VAC�?O", "EST�? VAC�?O");
				}
				for (int i = 0; i < result.size(); i++) {
					Log.v("resultado en tabla", result.get(i).text()
							+ " posicion: " + i);
				}
				String x[] = result.get(3).text().split(" ");
				resultado.add(x[2]);
				resultado.add(result.get(12).text());
				resultado.add(result.get(13).text());
				resultado.add(result.get(18).text());
				resultado.add(result.get(result.size() - 10).text());
				resultado.add(result.get(8).text());

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
				Toast.makeText(getApplicationContext(),
						"Error de conexión, por favor intenta más tarde", Toast.LENGTH_LONG)
						.show();
			}
			if (resultado.isEmpty()) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				odm.setBackgroundResource(R.drawable.odmexprress_black);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				castores.setBackgroundResource(R.drawable.castores_black);
				mProgressDialog.dismiss();
			}
		}

	}

	private class SearchResultPaquer extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		Elements clave, result;

		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(MainActivity.this);
			mProgressDialog.setTitle("Búsqueda en Paquer");
			mProgressDialog.setMessage("Buscando...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				Document document = Jsoup.connect(url1).get();
				result = document.select("div[class=span9 contenido] table tbody tr td");

				for (int i = 0; i < result.size(); i++) {
					Log.v("resultado en tabla", result.get(i).text()
							+ " posicion: " + i);
				}

				resultado.add(result.get(1).text());
				resultado.add(result.get(5).text());
				resultado.add(result.get(7).text());
				resultado.add(result.get(3).text());
				resultado.add("");
				String y []=result.get(7).text().split(",");
				resultado.add(y[0]);

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

		protected void onPostExecute(Void resultt) {
			if (resultado.isEmpty()) {
				Toast.makeText(getApplicationContext(),
						"Número de guía no encontrado", Toast.LENGTH_LONG)
						.show();
				odm.setBackgroundResource(R.drawable.odmexprress_black);
				mProgressDialog.dismiss();
			} else {
				Intent i = new Intent(MainActivity.this, Infodepaquete.class);
				i.putExtra("resultado", resultado);
				i.putExtra("id", id);
				startActivity(i);
				resultado.clear();
				castores.setBackgroundResource(R.drawable.castores_black);
				mProgressDialog.dismiss();
			}
		}
	}

	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == R.id.menu_new) {
			Intent i = new Intent(MainActivity.this, Misenvios.class);
			startActivity(i);
			return true;
		}
		return false;
	}

	public void imprime(Elements e) {
		for (int i = 0; i < e.size(); i++) {
			Log.v("Element", e.get(i).text() + " pos= " + i);
		}
	}

	public void imprimeArreglo(String x[]) {
		for (int i = 0; i < x.length; i++) {
			Log.v("Arreglo", x[i] + " pos = " + i);
		}

	}

	public String replaceAcutesHTML(String str) {

		str = str.replaceAll("&aacute;", "á");
		str = str.replaceAll("&eacute;", "é");
		str = str.replaceAll("&iacute;", "í");
		str = str.replaceAll("&oacute;", "ó");
		str = str.replaceAll("&uacute;", "ú");
		str = str.replaceAll("&Aacute;", "�?");
		str = str.replaceAll("&Eacute;", "É");
		str = str.replaceAll("&Iacute;", "�?");
		str = str.replaceAll("&Oacute;", "Ó");
		str = str.replaceAll("&Uacute;", "Ú");
		str = str.replaceAll("&ntilde;", "ñ");
		str = str.replaceAll("&Ntilde;", "Ñ");

		return str;
	}

	private void sendFeedback(String clave) {

		// Checks if the device is connected to the Internet.
		if (isDeviceConnected()) {

			// Set the action to be performed
			Intent sendIntent = new Intent();
			sendIntent.setAction(Intent.ACTION_SEND);

			// E-mail addresses that should be delivered to.
			sendIntent.putExtra(Intent.EXTRA_EMAIL,
					new String[] { "rastreomx@yahoo.com" });

			// Set the subject line of a message
			sendIntent.putExtra(Intent.EXTRA_SUBJECT, "Guía de aeroméxico");

			sendIntent.putExtra(Intent.EXTRA_TEXT, clave);

			// Set the data type of the message
			sendIntent.setType("plain/text");
			startActivity(Intent.createChooser(sendIntent,
					"mándanos tu guía de rastreo"));

		} else

			Toast.makeText(getApplicationContext(),
					"Your device is not connected to the Internet",
					Toast.LENGTH_LONG).show();
	}

	/**
	 * Checks if the device is connected to the Internet.
	 * 
	 * @param context
	 *            application context
	 * @return if the device is connected true, otherwise false.
	 */
	private boolean isDeviceConnected() {

		final ConnectivityManager connectManager = (ConnectivityManager) getApplicationContext()
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		return (connectManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
				.getState() == NetworkInfo.State.CONNECTED || connectManager
				.getNetworkInfo(ConnectivityManager.TYPE_WIFI).getState() == NetworkInfo.State.CONNECTED);
	}

}
