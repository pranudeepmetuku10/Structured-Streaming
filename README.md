# Spark Structured Streaming ETL Pipeline

A production-ready, end-to-end ETL pipeline demonstrating Apache Spark Structured Streaming with Spark SQL for real-time transaction processing.

## Overview

This project implements a complete streaming ETL pipeline for processing e-commerce transaction data. It showcases best practices for building scalable, fault-tolerant data pipelines using Spark Structured Streaming with a SQL-first approach.

### Key Features

- **Structured Streaming**: Real-time data processing using Spark's declarative streaming API
- **SQL-First Architecture**: All business logic implemented in external SQL files
- **Explicit Schema**: Type-safe data ingestion with schema enforcement
- **Fault Tolerance**: Checkpointing for exactly-once processing semantics
- **Production Ready**: Includes monitoring, error handling, and data quality checks

## Architecture

```
┌─────────────────┐
│  Data Source    │
│  (CSV Files)    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│              SPARK STRUCTURED STREAMING                 │
│                                                          │
│  ┌──────────────┐      ┌──────────────┐               │
│  │  Ingestion   │─────▶│Transformation│               │
│  │   (Schema)   │      │ (SQL Logic)  │               │
│  └──────────────┘      └──────┬───────┘               │
│                                │                        │
│                                ▼                        │
│                        ┌──────────────┐                │
│                        │ Aggregation  │                │
│                        │ (SQL Metrics)│                │
│                        └──────┬───────┘                │
│                                │                        │
│  ┌─────────────────────────────┼────────────────┐     │
│  │         Checkpointing       │                 │     │
│  │     (Fault Tolerance)       │                 │     │
│  └─────────────────────────────┼────────────────┘     │
└─────────────────────────────────┼──────────────────────┘
                                  │
                                  ▼
                   ┌──────────────────────────┐
                   │   Parquet Output         │
                   │  - Transformed Data      │
                   │  - Aggregated Metrics    │
                   └──────────────────────────┘
```

## Project Structure

```
Structured-Streaming/
│
├── notebooks/
│   ├── 01_data_source.ipynb           # Generate streaming data
│   ├── 02_streaming_ingestion.ipynb   # Set up Spark streaming source
│   ├── 03_transformations_sql.ipynb   # Apply SQL transformations
│   ├── 04_aggregations.ipynb          # Calculate real-time metrics
│   └── 05_sink_output.ipynb           # Write to Parquet with checkpointing
│
├── sql/
│   ├── transformations.sql            # Data cleaning & enrichment logic
│   └── aggregations.sql               # Analytics & KPI calculations
│
├── data/
│   ├── input/                         # Streaming CSV files
│   └── output/                        # Parquet output & checkpoints
│
├── requirements.txt                   # Python dependencies
└── README.md                          # This file
```

## Technologies Used

- **Apache Spark 3.x**: Distributed data processing
- **Structured Streaming**: Real-time stream processing
- **Spark SQL**: Declarative data transformations
- **Parquet**: Columnar storage format
- **Python 3.8+**: Primary development language
- **Jupyter Notebooks**: Interactive development environment

## Prerequisites

- Python 3.8 or higher
- Java 8 or 11 (required for Spark)
- At least 4GB RAM available
- macOS, Linux, or Windows with WSL

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/Structured-Streaming.git
cd Structured-Streaming
```

### 2. Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Verify Spark Installation

```bash
python -c "import pyspark; print(pyspark.__version__)"
```

## Usage

### Running the Pipeline

Execute notebooks in sequence:

#### 1. Generate Data Source

```bash
jupyter notebook notebooks/01_data_source.ipynb
```

This notebook:
- Generates realistic e-commerce transaction data
- Creates CSV files to simulate streaming source
- Produces 500 transaction records across 5 batches

#### 2. Set Up Streaming Ingestion

```bash
jupyter notebook notebooks/02_streaming_ingestion.ipynb
```

This notebook:
- Defines explicit schema for type safety
- Creates streaming DataFrame from CSV source
- Registers temporary SQL view for downstream processing

#### 3. Apply Transformations

```bash
jupyter notebook notebooks/03_transformations_sql.ipynb
```

This notebook:
- Loads transformation logic from `sql/transformations.sql`
- Cleans and validates data
- Creates derived columns (revenue, flags, date parts)
- Handles null values and invalid records

#### 4. Calculate Aggregations

```bash
jupyter notebook notebooks/04_aggregations.ipynb
```

This notebook:
- Loads aggregation queries from `sql/aggregations.sql`
- Computes real-time KPIs by product category
- Calculates revenue, volume, and customer metrics

#### 5. Write to Sink

```bash
jupyter notebook notebooks/05_sink_output.ipynb
```

This notebook:
- Configures streaming sinks with checkpointing
- Writes transformed data to Parquet (partitioned by date)
- Writes aggregated metrics to Parquet
- Monitors query progress and health

### Alternative: Run All Notebooks

```bash
jupyter notebook
# Navigate to notebooks/ and execute in order
```

## Data Flow

### Input Data Schema

```
transaction_id      : String (Primary Key)
user_id            : String (Customer ID)
product_id         : String (Product ID)
product_category   : String (Category)
amount             : Double (Transaction amount)
quantity           : Integer (Items purchased)
payment_method     : String (Payment type)
status             : String (completed|pending|failed|refunded)
event_time         : String (Timestamp)
country_code       : String (2-letter code)
discount_percent   : Double (Discount %, nullable)
customer_segment   : String (premium|regular|new, nullable)
```

### Transformation Logic

See [sql/transformations.sql](sql/transformations.sql) for complete logic:

- **Type Casting**: Convert string timestamps to proper timestamp types
- **Null Handling**: COALESCE for discount_percent, customer_segment
- **Derived Columns**:
  - `revenue`: amount × quantity × (1 - discount/100)
  - `is_high_value`: flag for transactions ≥ $200
  - `is_bulk_order`: flag for quantity > 3
  - `event_date`, `event_hour`: extracted from timestamp
- **Filtering**: Remove invalid records (null IDs, zero amounts)

### Aggregation Metrics

See [sql/aggregations.sql](sql/aggregations.sql) for complete metrics:

**Per Product Category:**
- Total transactions & revenue
- Unique customers & products
- Average transaction value
- Discount analysis
- High-value transaction counts
- Completion rates
- Customer segment breakdown
- Payment method distribution

## Output

### Transformed Data

Location: `data/output/transformed_transactions/`

- Format: Parquet
- Partitioning: By `event_date`
- Mode: Append
- Includes all cleaned and enriched transaction records

### Aggregated Metrics

Location: `data/output/transaction_metrics/`

- Format: Parquet
- Mode: Complete (full result table)
- Contains real-time KPIs by product category

### Checkpoints

Location: `data/output/checkpoints/`

- `transformed/`: Checkpoint for transformed data stream
- `aggregated/`: Checkpoint for aggregated metrics stream

**Do not delete checkpoint directories in production!**

## Streaming Concepts

### Why Structured Streaming?

- **Declarative API**: Write streaming logic as batch queries
- **Fault Tolerance**: Automatic recovery from failures
- **Exactly-Once**: Guaranteed processing semantics
- **Scalability**: Distributed processing across clusters
- **Late Data Handling**: Event-time processing with watermarks

### Output Modes

- **Append**: Write only new rows (used for transformed data)
- **Complete**: Write entire result table (used for aggregations)
- **Update**: Write only changed rows (requires Delta Lake)

### Checkpointing

Checkpoints enable:
- Recovery from failures
- Exactly-once processing
- State management for aggregations
- Offset tracking for source data

## Production Considerations

### Performance Tuning

```python
# Adjust based on your data volume
.config("spark.sql.shuffle.partitions", "200")  # Default: 200
.option("maxFilesPerTrigger", 10)               # Throttle ingestion
.trigger(processingTime='10 seconds')           # Batch interval
```

### Monitoring

Monitor these metrics:
- **Input Rate**: Records processed per second
- **Processing Time**: Time to process each micro-batch
- **Batch Duration**: End-to-end processing time
- **State Store Size**: Memory used for aggregations

### Fault Tolerance

- Checkpoints stored in fault-tolerant storage (HDFS, S3)
- Automatic recovery from driver/executor failures
- Idempotent writes to ensure data consistency

### Scaling

For production deployment:
- Deploy on Spark cluster (YARN, Kubernetes, Databricks)
- Increase executor memory and cores
- Tune shuffle partitions based on data volume
- Use external shuffle service for stability

## Common Issues & Solutions

### Issue: Schema Mismatch

**Error**: CSV data doesn't match schema

**Solution**: Ensure CSV headers match schema field names exactly

### Issue: Checkpoint Errors

**Error**: Cannot recover from checkpoint

**Solution**: Delete checkpoint directory (dev only) or fix schema evolution

### Issue: Memory Errors

**Error**: OutOfMemory for aggregations

**Solution**: Increase driver memory or use windowed aggregations

### Issue: Slow Processing

**Error**: Batches taking too long

**Solution**: Increase `maxFilesPerTrigger`, tune shuffle partitions

## Testing

### Unit Testing SQL

```bash
# Test transformations in spark-sql CLI
spark-sql -f sql/transformations.sql
```

### Integration Testing

1. Generate small dataset
2. Run full pipeline
3. Verify output counts and schema
4. Check data quality metrics

## Future Enhancements

- [ ] Add event-time watermarking for late data
- [ ] Implement windowed aggregations (hourly, daily)
- [ ] Integrate with Kafka for real-time ingestion
- [ ] Add Delta Lake for ACID transactions
- [ ] Implement data quality checks with Great Expectations
- [ ] Add monitoring dashboard with Grafana
- [ ] Set up CI/CD pipeline for automated testing
- [ ] Implement schema evolution handling

## Contributing

This is a portfolio project for demonstration purposes. For suggestions or improvements:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Contact

**Your Name**
- LinkedIn: [your-profile](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com
- GitHub: [@yourusername](https://github.com/yourusername)

## Acknowledgments

- Apache Spark documentation and community
- Structured Streaming programming guide
- Best practices from production deployments

---

**Note**: This is a demonstration project showcasing ETL pipeline development skills. For production use, additional security, monitoring, and infrastructure considerations are required.
