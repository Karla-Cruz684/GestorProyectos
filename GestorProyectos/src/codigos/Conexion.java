/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package codigos;

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.PreparedStatement;
import com.mysql.jdbc.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author Surface Book 2
 */
final public class Conexion {

    private final String base = "gestorproyectos";
    private final String url = "jdbc:mysql://localhost:3306/" + base;
    private Connection con = null;
    private final String usuario;
    private final String contraseña;

    public Conexion(String usuario, String contraseña) {
        this.usuario = usuario;
        this.contraseña = contraseña;
    }

    public Connection iniciar() throws ClassNotFoundException, SQLException {
        Class.forName("com.mysql.Driver");
        con = (Connection) DriverManager.getConnection(this.url, this.usuario, this.contraseña);
        return con;
    }

    public void cerrar() {
        if (con != null) 
            try {
            con.close();
        } catch (SQLException ex) {
            Logger.getLogger(Conexion.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public ResultSet call(String procedure) throws SQLException {
        PreparedStatement ps = (PreparedStatement) con.prepareStatement(procedure);
        ResultSet rs = (ResultSet) ps.executeQuery();
        return rs;
    }

    public boolean isConectado() {
        return !con.isClosed();
    }
    
}
