/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package codigos;

import java.util.logging.Level;
import java.util.logging.Logger;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
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
    private final String password;

    public Conexion(String usuario, String password) {
        this.usuario = usuario;
        this.password = password;
    }

    public Connection iniciar() throws SQLException {
        con = (Connection) DriverManager.getConnection(this.url, this.usuario, this.password);
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

    public boolean isConectado() throws SQLException {
        return !con.isClosed();
    }
    
}
