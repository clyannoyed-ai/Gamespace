import SwiftUI

struct ScheduleView: View {
    @State private var events: [Event] = []
    @State private var isLoading = true
    @State private var showAddEvent = false
    @State private var selectedDate = Date()
    
    var filteredEvents: [Event] {
        events.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar Header
                VStack(spacing: 12) {
                    Text("Schedule")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
                .padding()
                .background(Color(.systemGray6))
                
                if isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                } else if filteredEvents.isEmpty {
                    EmptyStateView(
                        title: "No Events",
                        description: "Create your first practice or game",
                        action: { showAddEvent = true }
                    )
                } else {
                    List(filteredEvents) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            EventRowView(event: event)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddEvent = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddEvent) {
                AddEventView(isPresented: $showAddEvent, onAdd: { event in
                    events.append(event)
                })
            }
        }
        .onAppear {
            loadEvents()
        }
    }
    
    private func loadEvents() {
        isLoading = true
        Task {
            // Load events from API
            isLoading = false
        }
    }
}

struct EventRowView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                    Label(event.eventType.rawValue, systemImage: eventIcon)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(event.startTime, style: .time)
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(event.startTime.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            if let location = event.location {
                Label(location, systemImage: "location.fill")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var eventIcon: String {
        switch event.eventType {
        case .practice:
            return "figure.soccer"
        case .game:
            return "sportscourt.fill"
        case .meeting:
            return "person.3.fill"
        case .training:
            return "dumbbell.fill"
        case .social:
            return "party.popper.fill"
        }
    }
}

struct EventDetailView: View {
    let event: Event
    @State private var attendees: [EventAttendance] = []
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Event Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        Label(event.eventType.rawValue, systemImage: "flag.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Label(
                            event.startTime.formatted(date: .abbreviated, time: .shortened),
                            systemImage: "clock.fill"
                        )
                        .font(.caption)
                        .foregroundColor(.green)
                    }
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    Section(header: Text("Details")) {
                        if let location = event.location {
                            InfoRow(label: "Location", value: location)
                        }
                        
                        let duration = Int(event.endTime.timeIntervalSince(event.startTime)) / 60
                        InfoRow(label: "Duration", value: "\(duration) minutes")
                    }
                    
                    if let description = event.description {
                        Section(header: Text("Description")) {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if !event.equipmentNeeded.isEmpty {
                        Section(header: Text("Equipment")) {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(event.equipmentNeeded, id: \\.self) { equipment in
                                    Label(equipment, systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .padding()
                
                // Attendance Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Attendance")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(attendees) { attendance in
                            AttendanceRow(attendance: attendance)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadAttendance()
        }
    }
    
    private func loadAttendance() {
        isLoading = true
        Task {
            // Load attendance
            isLoading = false
        }
    }
}

struct AttendanceRow: View {
    let attendance: EventAttendance
    
    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(attendance.status.rawValue)
                .font(.caption)
            
            Spacer()
        }
    }
    
    private var statusColor: Color {
        switch attendance.status {
        case .attending:
            return .green
        case .notAttending:
            return .red
        case .maybe:
            return .orange
        case .pending:
            return .gray
        }
    }
}

struct AddEventView: View {
    @Binding var isPresented: Bool
    var onAdd: (Event) -> Void
    
    @State private var title = ""
    @State private var eventType = EventType.practice
    @State private var startDate = Date()
    @State private var location = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Event Title", text: $title)
                    Picker("Type", selection: $eventType) {
                        ForEach([EventType.practice, .game, .training, .meeting, .social], id: \\.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section("Date & Time") {
                    DatePicker("Start", selection: $startDate)
                    TextField("Location", text: $location)
                }
                
                Section {
                    Button("Create Event") {
                        createEvent()
                    }
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func createEvent() {
        // Create event
        isPresented = false
    }
}

#Preview {
    ScheduleView()
}
