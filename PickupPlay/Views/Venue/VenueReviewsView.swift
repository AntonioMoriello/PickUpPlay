import SwiftUI

struct VenueReviewsView: View {
    let venue: Venue
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var venueViewModel = VenueViewModel()
    @State private var showWriteReview = false
    @State private var newRating: Double = 5.0
    @State private var newComment: String = ""

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text(String(format: "%.1f", venue.rating))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.gradient)

                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(venue.rating.rounded()) ? "star.fill" : "star")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.accentAmber)
                            }
                        }

                        Text("\(venue.reviewCount) reviews")
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    Button {
                        showWriteReview = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("Write a Review")
                        }
                    }
                    .buttonStyle(AppPrimaryButtonStyle())
                    .padding(.horizontal, 20)

                    if venueViewModel.isLoading {
                        ProgressView()
                            .frame(height: 100)
                    } else if venueViewModel.reviews.isEmpty {
                        EmptyStateView(
                            icon: "star.bubble",
                            title: "No Reviews Yet",
                            message: "Be the first to review this venue!"
                        )
                        .frame(height: 200)
                    } else {
                        ForEach(venueViewModel.reviews) { review in
                            ReviewCard(review: review)
                                .padding(.horizontal, 16)
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showWriteReview) {
            writeReviewSheet
        }
        .onAppear {
            Task { await venueViewModel.fetchReviews(venueId: venue.id) }
        }
        .errorBanner(message: $venueViewModel.errorMessage)
    }

    private var writeReviewSheet: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        Text("Rate \(venue.name)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .padding(.top, 20)

                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    newRating = Double(star)
                                } label: {
                                    Image(systemName: star <= Int(newRating) ? "star.fill" : "star")
                                        .font(.system(size: 36))
                                        .foregroundColor(AppTheme.accentAmber)
                                }
                            }
                        }

                        Text(ratingText)
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Review")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            TextField("Share your experience...", text: $newComment, axis: .vertical)
                                .lineLimit(4...8)
                                .modernInput()
                        }
                        .padding(.horizontal, 20)

                        Button("Submit Review") {
                            Task { await submitReview() }
                        }
                        .buttonStyle(AppPrimaryButtonStyle(isEnabled: !newComment.isEmpty))
                        .disabled(newComment.isEmpty)
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Write Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { showWriteReview = false }
                        .fontDesign(.rounded)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var ratingText: String {
        switch Int(newRating) {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Great"
        case 5: return "Excellent"
        default: return ""
        }
    }

    private func submitReview() async {
        guard let userId = authViewModel.currentUser?.id else { return }
        let review = VenueReview.new(
            venueId: venue.id,
            userId: userId,
            rating: newRating,
            comment: newComment
        )
        await venueViewModel.submitReview(review)
        showWriteReview = false
        newComment = ""
        newRating = 5.0
    }
}

struct ReviewCard: View {
    let review: VenueReview

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(AppTheme.gradient)
                        .frame(width: 36, height: 36)
                    Text(String(review.userId.prefix(1)).uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.userId)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .lineLimit(1)
                    Text(review.createdAt, style: .date)
                        .font(.caption2)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(review.rating.rounded()) ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(AppTheme.accentAmber)
                    }
                }
            }

            if !review.comment.isEmpty {
                Text(review.comment)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
            }

            if review.helpfulCount > 0 {
                Text("\(review.helpfulCount) found this helpful")
                    .font(.caption2)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .glassCard(padding: 0)
    }
}
