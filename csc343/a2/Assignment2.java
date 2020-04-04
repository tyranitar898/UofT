import java.sql.*;
import java.util.Arrays;
import java.util.List;

public class Assignment2 {

    // A connection to the database
    Connection connection;

    // Can use if you wish: seat letters
    List<String> seatLetters = Arrays.asList("A", "B", "C", "D", "E", "F");

    Assignment2() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Connects and sets the search path.
     * <p>
     * Establishes a connection to be used for this session, assigning it to
     * the instance variable 'connection'.  In addition, sets the search
     * path to 'air_travel, public'.
     *
     * @param url      the url for the database
     * @param username the username to connect to the database
     * @param password the password to connect to the database
     * @return true if connecting is successful, false otherwise
     */
    public boolean connectDB(String URL, String username, String password) {
        PreparedStatement ps = null;

        try {
            connection = DriverManager.getConnection(URL, username, password);

            String setSearchPath = "SET search_path = air_travel, public";
            ps = connection.prepareStatement(setSearchPath);
            ps.executeUpdate();
            return true;
        } catch (SQLException se) {
            return false;
        } finally {
            try {
                ps.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }

    /**
     * Closes the database connection.
     *
     * @return true if the closing was successful, false otherwise
     */
    public boolean disconnectDB() {
        try {
            connection.close();
            return true;
        } catch (SQLException se) {
            return false;
        }
    }

    /* ======================= Airline-related methods ======================= */

    /**
     * Attempts to book a flight for a passenger in a particular seat class.
     * Does so by inserting a row into the Booking table.
     * <p>
     * Read handout for information on how seats are booked.
     * Returns false if seat can't be booked, or if passenger or flight cannot be found.
     *
     * @param passID    id of the passenger
     * @param flightID  id of the flight
     * @param seatClass the class of the seat (economy, business, or first)
     * @return true if the booking was successful, false otherwise.
     */
    public boolean bookSeat(int passID, int flightID, String seatClass) {
        // Check remaining capacity
        int fullness = isFull(seatClass, flightID);
        if (fullness == 0) {
            return false;
        }

        // Assign seats
        String row;
        String letter;
        if (fullness == 2) {
            row = null;
            letter = null;
        } else {
            String[] assignedSeat = getAvailableSeat(seatClass, flightID);
            row = assignedSeat[0];
            letter = assignedSeat[1];
        }

        return insertNewBooking(passID, flightID, seatClass, row, letter);
    }

    /**
     * Attempts to upgrade overbooked economy passengers to business class
     * or first class (in that order until each seat class is filled).
     * Does so by altering the database records for the bookings such that the
     * seat and seat_class are updated if an upgrade can be processed.
     * <p>
     * Upgrades should happen in order of earliest booking timestamp first.
     * <p>
     * If economy passengers left over without a seat (i.e. more than 10 overbooked passengers or not enough higher class seats),
     * remove their bookings from the database.
     *
     * @param flightID The flight to upgrade passengers in.
     * @return the number of passengers upgraded, or -1 if an error occured.
     */
    public int upgrade(int flightID) {
        String queryString =
            "SELECT * " +
            "FROM booking " +
            "WHERE flight_id = ? AND row IS NULL " +
            "ORDER BY datetime";
        PreparedStatement ps = null;
        ResultSet rs = null;
        int numUpgraded = 0;

        try {
            ps = connection.prepareStatement(queryString);
            ps.setInt(1, flightID);
            rs = ps.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("id");
                if (isFull("business", flightID) == 1 &&
                    upgradeSeat(flightID, id, "business")) {
                    numUpgraded++;
                } else if (isFull("first", flightID) == 1 &&
                    upgradeSeat(flightID, id, "first")) {
                    numUpgraded++;
                }
            }
            return numUpgraded;
        } catch (SQLException se) {
            se.printStackTrace();
            return -1;
        } finally {
            try {
                rs.close();
                ps.close();
            } catch (SQLException ignored) {
            }
        }
    }


    /* ----------------------- Helper functions below  ------------------------- */

    // A helpful function for adding a timestamp to new bookings.
    // Example of setting a timestamp in a PreparedStatement:
    // ps.setTimestamp(1, getCurrentTimeStamp());

    /**
     * Returns a SQL Timestamp object of the current time.
     *
     * @return Timestamp of current time.
     */
    private java.sql.Timestamp getCurrentTimeStamp() {
        java.util.Date now = new java.util.Date();
        return new java.sql.Timestamp(now.getTime());
    }

    // Add more helper functions below if desired.

    /**
     * Returns the capacity of plane given flightID.
     *
     * @param seatClass the seat class to search capacity for.
     * @param flightID  the ID of flight to search capacity for.
     * @return capacity of seat class on plane with flightID.
     */
    private int getCapacity(String seatClass, int flightID) {
        String seatCategory = "capacity_" + seatClass;
        String queryString =
            "SELECT * " +
            "FROM flight f JOIN plane ON f.plane = tail_number " +
            "WHERE f.id = ?";
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ps = connection.prepareStatement(queryString);
//            ps.setString(1, seatCategory);
            ps.setInt(1, flightID);

            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(seatCategory) : -1;
        } catch (SQLException se) {
            return -1;
        } finally {
            try {
                rs.close();
                ps.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }

    private int getCurrPass(String seatClass, int flightID) {
        String queryString =
            "SELECT count(*) as curr_capacity " +
            "FROM booking " +
            "WHERE flight_id = ? and seat_class = ?::seat_class";
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ps = connection.prepareStatement(queryString);
            ps.setInt(1, flightID);
            ps.setString(2, seatClass);

            rs = ps.executeQuery();
            return rs.next() ? rs.getInt("curr_capacity") : -1;
        } catch (SQLException se) {
            return -1;
        } finally {
            try {
                rs.close();
                ps.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }

    private int isFull(String seatClass, int flightID) {
        int capacity = getCapacity(seatClass, flightID);
        int currNum = getCurrPass(seatClass, flightID);
        if (currNum < capacity) {
            return 1;
        } else if (seatClass.equals("economy") & currNum < capacity + 10) {
            return 2;
        }

        return 0;
    }

    private String[] getAvailableSeat(String seatClass, int flightID) {
        String queryString =
            "SELECT * " +
            "FROM booking " +
            "WHERE flight_id = ? and seat_class = ?::seat_class " +
            "ORDER BY row desc, letter desc";
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ps = connection.prepareStatement(queryString);
            ps.setInt(1, flightID);
            ps.setString(2, seatClass);

            rs = ps.executeQuery();
            int row = 0;
            String letter = null;
            while (rs.next()) {
                row = rs.getInt("row");
                letter = rs.getString("letter");
                if (!letter.equals("F")) {
                    int currLetterIndex = seatLetters.indexOf(letter);
                    letter = seatLetters.get(currLetterIndex + 1);
                } else {
                    row++;
                    letter = seatLetters.get(0);
                }
            }
            return new String[]{((Integer) row).toString(), letter};
        } catch (SQLException se) {
            return null;
        } finally {
            try {
                rs.close();
                ps.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }

    private boolean insertNewBooking(int passID, int flightID, String seatClass,
                                     String row, String letter) {
        String getID = "SELECT id FROM booking ORDER BY id DESC";
        String getPrice = "SELECT * FROM price WHERE flight_id = ?";
        String insertValues =
            "INSERT INTO booking VALUES " +
            "(?, ?, ?, date_trunc('second', current_timestamp), ?, ?::seat_class, ?, ?)";
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ps = connection.prepareStatement(getID);
            rs = ps.executeQuery();
            int newBookingID = -1;
            while (rs.next() & newBookingID == -1) {
                newBookingID = rs.getInt("id") + 1;
            }

            ps = connection.prepareStatement(getPrice);
            ps.setInt(1, flightID);
            rs = ps.executeQuery();
            int price = -1;
            while (rs.next() & price == -1) {
                price = rs.getInt(seatClass);
            }

            ps = connection.prepareStatement(insertValues);
            ps.setInt(1, newBookingID);
            ps.setInt(2, passID);
            ps.setInt(3, flightID);
            ps.setInt(4, price);
            ps.setString(5, seatClass);
            if (row == null) {
                ps.setNull(6, Types.INTEGER);
                ps.setNull(7, Types.CHAR);
            } else {
                ps.setInt(6, Integer.parseInt(row));
                ps.setString(7, letter);
            }
            ps.executeUpdate();
            return true;

        } catch (SQLException se) {
            return false;
        } finally {
            try {
                rs.close();
                ps.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }

    private boolean upgradeSeat(int flightID, int id, String seatClass) {
        String alterQuery =
            "UPDATE booking " +
            "SET row = ?, letter = ?, seat_class = ?::seat_class " +
            "WHERE id = ?";
        PreparedStatement ps = null;

        try {
            String[] latestSeat = getAvailableSeat(seatClass, flightID);
            if (latestSeat != null) {
                ps = connection.prepareStatement(alterQuery);
                ps.setInt(1, Integer.parseInt(latestSeat[0]));
                ps.setString(2, latestSeat[1]);
                ps.setString(3, seatClass);
                ps.setInt(4, id);
                ps.executeUpdate();
                return true;
            }
            return false;
        } catch (SQLException ignored) {
            return false;
        } finally {
            try {
                ps.close();
            } catch (SQLException ignored) {
            }
        }
    }


    /* ----------------------- Main method below  ------------------------- */

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Running the code!");
        try {
            Assignment2 obj = new Assignment2();
            obj.connectDB("jdbc:postgresql://localhost:5432/csc343h-shile4", "shile4", "");
            System.out.println("Connection established!");
//            boolean success = obj.bookSeat(1, 5, "economy");
//            if (success) {
//                System.out.println("Booking success");
//            } else {
//                System.out.println("Booking failed");
//            }

            int num_upgraded = obj.upgrade(5);
            System.out.println("Upgraded: " + num_upgraded);
            obj.disconnectDB();
            System.out.println("disconnected");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
