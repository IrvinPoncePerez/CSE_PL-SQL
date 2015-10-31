package touchesbegan.com.rastreomx;

import touchesbegan.com.rastreomx.R;
import touchesbegan.rastreomx.database.MySQLiteHelper;
import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.Switch;
import android.widget.TextView;

public class Ajustes extends Activity {
	Switch switch1;
    TextView tvStateofToggleButton;
    MySQLiteHelper bd;
    boolean flag=false;
    Button btn;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_ajustes);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
		
		bd= new MySQLiteHelper(this);
		ActionBar bar = getActionBar();
		bar.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#F05157")));		
		switch1 = (Switch) findViewById(R.id.switch1);
		btn = (Button) findViewById(R.id.cancelar);
		btn.setBackgroundColor(Color.argb(127, 255, 0, 0));
		btn.setTextColor(Color.WHITE);
		tvStateofToggleButton=(TextView)findViewById(R.id.textViewprueba);
		//tvStateofToggleButton.setText("OFF");
			
		switch1.setOnCheckedChangeListener(new OnCheckedChangeListener() {
			@Override
			public void onCheckedChanged(CompoundButton buttonView,
					boolean isChecked) {
				if(isChecked){
					//tvStateofToggleButton.setText("ON");
					bd.deleteAll();
					switch1.setChecked(true);
					flag=true;
					
				}else{
					flag=false;
					//tvStateofToggleButton.setText("OFF");
				}

			}
		});
		
		switch1.setChecked(flag);

	}

	
	public void Volver(View v){
		if(flag==true){
			switch1.setChecked(flag);
		}
	      Intent volver = new Intent(this,Misenvios.class);
			startActivity(volver);
	}
	
	public void masinfo(View v){
		Intent mas = new Intent(this,Masinfo.class);
		startActivity(mas);
	}
	
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.ajustes, menu);
		return true;
	}

}
