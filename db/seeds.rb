# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

TimeSlot.create([
                  { day: 'MWF', start_time: '8:00', end_time: '8:50', slot_type: 'LEC' },
                  { day: 'MWF', start_time: '9:10', end_time: '10:00', slot_type: 'LEC' },
                  { day: 'MWF', start_time: '10:20', end_time: '11:10', slot_type: 'LEC' },
                  { day: 'MWF', start_time: '11:30', end_time: '12:20', slot_type: 'LEC' },
                  { day: 'MWF', start_time: '12:40', end_time: '13:30', slot_type: 'LEC' },
                  { day: 'MWF', start_time: '13:50', end_time: '14:20', slot_type: 'LEC' },
                  { day: 'MWF', start_time: '15:00', end_time: '15:50', slot_type: 'LEC' },

                  { day: 'MW', start_time: '16:10', end_time: '17:25', slot_type: 'LEC' },
                  { day: 'MW', start_time: '17:45', end_time: '19:00', slot_type: 'LEC' },

                  { day: 'TR', start_time: '8:00', end_time: '9:15', slot_type: 'LEC' },
                  { day: 'TR', start_time: '9:35', end_time: '10:50', slot_type: 'LEC' },
                  { day: 'TR', start_time: '11:10', end_time: '12:25', slot_type: 'LEC' },
                  { day: 'TR', start_time: '12:45', end_time: '14:00', slot_type: 'LEC' },
                  { day: 'TR', start_time: '14:20', end_time: '15:35', slot_type: 'LEC' },
                  { day: 'TR', start_time: '16:55', end_time: '17:10', slot_type: 'LEC' },
                  { day: 'TR', start_time: '17:30', end_time: '18:45', slot_type: 'LEC' },

                  { day: 'MW', start_time: '8:00', end_time: '8:50', slot_type: 'LAB' },
                  { day: 'MW', start_time: '9:10', end_time: '10:00', slot_type: 'LAB' },
                  { day: 'MW', start_time: '10:20', end_time: '11:10', slot_type: 'LAB' },
                  { day: 'MW', start_time: '11:30', end_time: '12:20', slot_type: 'LAB' },
                  { day: 'MW', start_time: '12:40', end_time: '13:30', slot_type: 'LAB' },
                  { day: 'MW', start_time: '13:50', end_time: '14:40', slot_type: 'LAB' },
                  { day: 'MW', start_time: '15:00', end_time: '15:50', slot_type: 'LAB' },
                  { day: 'MW', start_time: '16:10', end_time: '17:00', slot_type: 'LAB' },
                  { day: 'MW', start_time: '17:45', end_time: '18:35', slot_type: 'LAB' },
                  { day: 'MW', start_time: '19:10', end_time: '19:50', slot_type: 'LAB' },

                  { day: 'TR', start_time: '8:25', end_time: '9:15', slot_type: 'LAB' },
                  { day: 'TR', start_time: '9:35', end_time: '10:25', slot_type: 'LAB' },
                  { day: 'TR', start_time: '11:35', end_time: '12:25', slot_type: 'LAB' },
                  { day: 'TR', start_time: '12:45', end_time: '13:35', slot_type: 'LAB' },
                  { day: 'TR', start_time: '14:35', end_time: '15:25', slot_type: 'LAB' },
                  { day: 'TR', start_time: '15:55', end_time: '16:45', slot_type: 'LAB' },
                  { day: 'TR', start_time: '17:30', end_time: '18:20', slot_type: 'LAB' },
                  { day: 'TR', start_time: '18:40', end_time: '19:30', slot_type: 'LAB' },

                  { day: 'F', start_time: '8:00', end_time: '9:40', slot_type: 'LAB' },
                  { day: 'F', start_time: '10:20', end_time: '12:00', slot_type: 'LAB' },
                  { day: 'F', start_time: '12:40', end_time: '14:20', slot_type: 'LAB' },

                  { day: 'F', start_time: '8:00', end_time: '8:50', slot_type: 'LAB' },
                  { day: 'F', start_time: '9:10', end_time: '10:00', slot_type: 'LAB' },
                  { day: 'F', start_time: '10:20', end_time: '11:10', slot_type: 'LAB' },
                  { day: 'F', start_time: '11:30', end_time: '12:20', slot_type: 'LAB' },
                  { day: 'F', start_time: '12:40', end_time: '13:30', slot_type: 'LAB' },
                  { day: 'F', start_time: '13:50', end_time: '14:40', slot_type: 'LAB' },
                  { day: 'F', start_time: '15:00', end_time: '15:50', slot_type: 'LAB' }

<<<<<<< HEAD
])

=======
                ])
>>>>>>> 15e82e91959c9a7f56464c8ed57d02f89bf544eb
