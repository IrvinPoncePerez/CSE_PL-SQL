package touchesbegan.com.rastreomx;

import touchesbegan.com.rastreomx.R;
import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class EnviaGuiaActivity extends Activity {
	EditText numGuia, paqueteria, correo;
	String email, subject, body;
	Button enviar;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_envia_guia);
		ActionBar bar = getActionBar();
		bar.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#F05157")));
		bar.setTitle("Envía guía");
		numGuia = (EditText) findViewById(R.id.numGuia);
		paqueteria = (EditText) findViewById(R.id.paqueteria);
		correo = (EditText) findViewById(R.id.correoText);
		enviar = (Button) findViewById(R.id.envia);
		subject = "Guía de paquete";
		enviar = (Button)findViewById(R.id.otra);
		enviar.setBackgroundColor(Color.argb(127, 255, 0, 0));
		enviar.setTextColor(Color.WHITE);

	}

	public void envia(View v) {
		if (numGuia.getText().length() == 0
				|| paqueteria.getText().length() == 0
				|| correo.getText().length() == 0) {

			Toast.makeText(getApplicationContext(), "Por favor llena todos los campos", Toast.LENGTH_SHORT).show();
		} else {
			Intent itSend = new Intent(android.content.Intent.ACTION_SEND);
			itSend.setType("plain/text");
			itSend.putExtra(Intent.EXTRA_EMAIL,
					new String[] { "rastreomx@yahoo.com" });
			itSend.putExtra(Intent.EXTRA_SUBJECT, subject);
			body = "número de guía: " + numGuia.getText() + "\n"
					+ "paquetería: " + paqueteria.getText() + "\n"
					+ "correo remitente: " + correo.getText();
			itSend.putExtra(android.content.Intent.EXTRA_TEXT, body);
			startActivity(itSend);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.envia_guia, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();
		if (id == R.id.action_settings) {
			return true;
		}
		return super.onOptionsItemSelected(item);
	}
}
